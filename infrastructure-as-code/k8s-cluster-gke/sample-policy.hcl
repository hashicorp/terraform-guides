# Vault Policy file for user roger

# Access to secret/roger
path "secret/roger/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Additional access for UI
path "secret/" {
  capabilities = ["list"]
}
path "secret/roger" {
  capabilities = ["list"]
}
path "sys/mounts" {
  capabilities = ["read", "list"]
}

# Ability to provision Kubernetes auth backends
path "sys/auth/roger*" {
  capabilities = ["sudo", "create", "read", "update", "delete", "list"]
}
path "sys/auth" {
  capabilities = ["read", "list"]
}
path "auth/roger*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Needed for the Terraform Vault Provider
path "auth/token/create" {
  capabilities = ["create", "read", "update", "list"]
}
