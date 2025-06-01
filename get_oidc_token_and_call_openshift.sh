#!/bin/bash

# Inputs
TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
KEYVAULT_NAME="your-vault-name"
SECRET_NAME="client-secret"  # Azure Key Vault secret name
SCOPE="openid profile email"
OPENSHIFT_API="https://api.openshift.example.com:6443"
TOKEN_URL="https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token"

# 🔐 Fetch client secret from Azure Key Vault
echo "🔐 Fetching client secret from Azure Key Vault: $KEYVAULT_NAME"
CLIENT_SECRET=$(az keyvault secret show --name "$SECRET_NAME" --vault-name "$KEYVAULT_NAME" --query "value" -o tsv)

if [[ -z "$CLIENT_SECRET" ]]; then
  echo "Failed to retrieve client secret from Azure Key Vault"
  exit 1
fi

echo "Requesting access token from Azure AD..."

# Get JWT access token from AAD
TOKEN_RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  -d "scope=$SCOPE")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
  echo "Failed to get access token"
  echo "$TOKEN_RESPONSE"
  exit 1
fi

echo "Access Token retrieved"

# Call OpenShift API using JWT
echo "Calling OpenShift API with JWT..."

API_RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/json" \
  "$OPENSHIFT_API/apis/user.openshift.io/v1/users/~")

echo "OpenShift User Info:"
echo "$API_RESPONSE" | jq
