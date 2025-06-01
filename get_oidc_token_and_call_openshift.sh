#!/bin/bash

# Required environment variables
TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
CLIENT_SECRET="your-client-secret"  # Or use device code flow
RESOURCE="api://openshift-api"      # May vary depending on your setup
SCOPE="openid profile email"        # Add your custom scopes if needed
OPENSHIFT_API="https://api.openshift.example.com:6443"

# Use MS OAuth 2.0 token endpoint
TOKEN_URL="https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token"

echo "Requesting JWT token from Azure AD..."

# Generate JWT via client_credentials grant
TOKEN_RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  -d "scope=$SCOPE")

# Extract token
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
  echo "Failed to get access token"
  echo "$TOKEN_RESPONSE"
  exit 1
fi

echo "Access Token retrieved from Azure AD"

# Call OpenShift API using this JWT
echo "Calling OpenShift API with OIDC token..."

API_RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/json" \
  "$OPENSHIFT_API/apis/user.openshift.io/v1/users/~")

echo "OpenShift User Info:"
echo "$API_RESPONSE" | jq
