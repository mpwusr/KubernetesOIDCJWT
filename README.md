# 🔐 OIDC Token Generator for OpenShift API (Azure AD + Key Vault)

This script requests a JWT access token from Azure Active Directory using the OAuth2 `client_credentials` flow, pulling the client secret securely from **Azure Key Vault**, and uses it to authenticate against the OpenShift API.

---

## Dependencies

Install:

```bash
brew install jq curl azure-cli
```
## Notes
* Token TTL is short (usually 3600 seconds), but can be refreshed or re-issued as needed.
* Never commit your CLIENT_SECRET to version control. Use .env files, secret managers, or managed identities in production environments.
* You can replace the client_credentials flow with:

## Device code flow (for human login without client secret), or

## Authorization code flow (for full OAuth2 interactive flow)

## Secret Setup
Store your Azure AD app secret in Azure Key Vault:
```
az keyvault secret set --vault-name <your-vault-name> --name client-secret --value "<CLIENT_SECRET>"
```

## Testing and Usage
1. Make the script executable:

```
chmod +x get_oidc_token_and_call_openshift.sh
```
2. Run the script:
```
./get_oidc_token_and_call_openshift.sh
```
If the OpenShift cluster is correctly configured to trust Azure AD, the script will call:
```
/apis/user.openshift.io/v1/users/~
```
And return output similar to:
```
json
{
  "kind": "User",
  "metadata": {
    "name": "john.doe@example.com"
  },
  ...
}
```
