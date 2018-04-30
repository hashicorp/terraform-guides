#!/bin/bash

echo "[---Begin install-vault-systemd.sh---]"

echo "Setup Vault user"
export GROUP=vault
export USER=vault
export COMMENT=Vault
export HOME=/srv/vault
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/setup-user.sh | bash

echo "Install Vault"
export VERSION=${vault_version}
export URL=${vault_url}
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/vault/scripts/install-vault.sh | bash

echo "Install Vault Systemd"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/vault/scripts/install-vault-systemd.sh | bash

echo "Cleanup install files"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/cleanup.sh | bash

echo "Set variables"
VAULT_CONFIG_FILE=/etc/vault.d/default.hcl
VAULT_CONFIG_OVERRIDE_FILE=/etc/vault.d/z-override.hcl

echo "Minimal configuration for Vault"
cat <<CONFIG | sudo tee $VAULT_CONFIG_FILE
cluster_name = "${name}"
CONFIG

echo "Update Vault configuration file permissions"
sudo chown vault:vault $VAULT_CONFIG_FILE

if [ ${vault_override} == true ] || [ ${vault_override} == 1 ]; then
  echo "Add custom Vault server override config"
  cat <<CONFIG | sudo tee $VAULT_CONFIG_OVERRIDE_FILE
${vault_config}
CONFIG

  echo "Update Vault configuration override file permissions"
  sudo chown vault:vault $VAULT_CONFIG_OVERRIDE_FILE

  echo "If Vault config is overridden, don't start Vault in -dev mode"
  echo '' | sudo tee /etc/vault.d/vault.conf
fi

echo "Restart Vault"
sudo systemctl restart vault

echo "[---install-vault-systemd.sh Complete---]"
