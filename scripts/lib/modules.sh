#!/bin/bash

create_resource_group(){
    local rg_name="$1" location="$2"
    if ["$(az group exists -n "$rg_name")" = false]; then
        az group create -n "$rg_name" -l "$location"
    fi
}

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
}

create_container(){
    local cont_name="$1" acct_name="$2"
    if [ "$(az storage container exists -n "$cont_name" --account-name "$acct_name" --auth-mode login --query exists)" = "false" ]; then
        az storage container create \
            -n "$cont_name" \
            --account-name "$acct_name" \
            --auth-mode login
    fi
}