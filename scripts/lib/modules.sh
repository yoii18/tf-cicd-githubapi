#!/bin/bash

create_resource_group(){
    local rg_name="$1" location="$2"
    if [ "$(az group exists -n "$rg_name")" = "false" ]; then
        az group create -n "$rg_name" -l "$location"
    fi
}  # ← closing brace

create_storage_account(){
    local acct_name="$1" rg_name="$2"
    if ! az storage account show -n "$acct_name" -g "$rg_name" &>/dev/null; then
        az storage account create \
            -n "$acct_name" \
            -g "$rg_name" \
            --min-tls-version "TLS1_2" \
            --sku "Standard_LRS" \
            --hns true
    fi
}  # ← closing brace

create_container(){
    local cont_name="$1" acct_name="$2"
    if [ "$(az storage container exists -n "$cont_name" --account-name "$acct_name" --auth-mode login --query exists)" = "false" ]; then
        az storage container create \
            -n "$cont_name" \
            --account-name "$acct_name" \
            --auth-mode login
    fi
}  # ← closing brace

create_app_with_federated_creds() {
    local display_name="$1" repo="$2" env_name="$3" sub_id="$4" rg="$5" acct="$6" fed_name="$7"
    local app_id

    app_id="$(az ad app list \
        --filter "displayname eq '$display_name'" \
        --query "[0].appId" \
        -o tsv)"

    if [ -z "$app_id" ]; then
        app_id="$(az ad app create \
            --display-name "$display_name" \
            --query appId \
            -o tsv)"
    fi

    az ad sp create --id "$app_id" >/dev/null 2>&1 || true

    existing=$(az ad app federated-credential list \
        --id "$app_id" \
        --query "[?name=='$fed_name'].name" \
        -o tsv)

    if [ -z "$existing" ]; then
        az ad app federated-credential create \
            --id "$app_id" \
            --parameters "{
                \"name\": \"${fed_name}\",
                \"issuer\": \"https://token.actions.githubusercontent.com\",
                \"subject\": \"repo:${repo}:environment:${env_name}\",
                \"audiences\": [\"api://AzureADTokenExchange\"]
            }"
    fi

    echo "$app_id"
}  # ← closing brace

create_group_with_role(){
    local grp_name="$1" sub_id="$2" sp_obj_id="$3"
    local grp_id

    grp_id="$(az ad group list \
        --filter "displayname eq '$grp_name'" \
        --query "[0].id" \
        -o tsv)"

    if [ -z "$grp_id" ]; then
        grp_id="$(az ad group create \
            --display-name "$grp_name" \
            --mail-nickname "$grp_name" \
            --query "id" \
            -o tsv)"
    fi

    az role assignment create \
        --assignee-object-id "$grp_id" \
        --assignee-principal-type "Group" \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$sub_id" >/dev/null 2>&1 || true

    az role assignment create \
        --assignee-object-id "$grp_id" \
        --assignee-principal-type "Group" \
        --role "Contributor" \
        --scope "/subscriptions/$sub_id" >/dev/null 2>&1 || true

    az rest \
        --method POST \
        --uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments" \
        --headers "Content-Type=application/json" \
        --body "{
            \"@odata.type\": \"#microsoft.graph.unifiedRoleAssignment\",
            \"principalId\": \"${sp_obj_id}\",
            \"roleDefinitionId\": \"fdd7a751-b60b-444a-984c-02652fe8fa1c\",
            \"directoryScopeId\": \"/\"
        }" >/dev/null 2>&1 || true

    echo "$grp_id"
}  # ← closing brace