#!/bin/bash

ENV="${1:?Usage: $0 <staging|prod>}"
ENV_FILE="$(dirname "$0")/env/${ENV}.env"
source "$ENV_FILE"

APP_ID=$(az ad app list \
  --filter "displayname eq '$APP_DISPLAY_NAME'" \
  --query "[0].appId" -o tsv)

SP_OBJ_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)

GRP_ID=$(az ad group list \
  --filter "displayname eq 'storage-blob-contributors-group'" \
  --query "[0].id" -o tsv)

echo "=== App Registration ==="
echo "App ID:        $APP_ID"
echo "SP Object ID:  $SP_OBJ_ID"
echo ""

echo "=== Federated Credential ==="
az ad app federated-credential list --id "$APP_ID" --query "[].{Name:name, Subject:subject}" -o table
echo ""

echo "=== Group ==="
echo "Group ID: $GRP_ID"
echo ""

echo "=== Azure RBAC Role Assignments on Group ==="
az role assignment list \
  --assignee "$GRP_ID" \
  --query "[].{Role:roleDefinitionName, Scope:scope}" \
  -o table
echo ""

echo "=== Entra Directory Role on SP (Application Administrator) ==="
az rest \
  --method GET \
  --uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?\$filter=principalId eq '$SP_OBJ_ID' and roleDefinitionId eq 'fdd7a751-b60b-444a-984c-02652fe8fa1c'" \
  --query "value[0].id" -o tsv | \
  { read id; [ -n "$id" ] && echo "✅ Application Administrator role IS assigned to SP" || echo "❌ Application Administrator role NOT found on SP"; }