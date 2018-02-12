#!/bin/bash

echo "[---Begin install-vault-systemd.sh---]"

echo "Download scripts"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/shared/scripts/download-guides-configuration.sh | sudo bash

echo "Run base script"
bash /tmp/shared/scripts/base.sh

echo "Setup Vault user"
export GROUP=vault
export USER=vault
export COMMENT=Vault
export HOME=/srv/vault
bash /tmp/shared/scripts/setup-user.sh

echo "Install Vault"
export VERSION=${vault_version}
export URL=${vault_url}
bash /tmp/vault/scripts/install-vault.sh

echo "Install Vault Systemd"
bash /tmp/vault/scripts/install-vault-systemd.sh

echo "Cleanup install files"
sudo rm -rf /tmp/*
sudo rm -rf /tmp/.git*

echo "[---install-vault-systemd.sh Complete---]"
