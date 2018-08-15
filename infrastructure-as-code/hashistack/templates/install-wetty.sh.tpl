#!/bin/bash

echo "[---Begin install-wetty.sh---]"

echo "Install Wetty"
export GROUP=${wetty_user}
export USER=${wetty_user}
export PASSWORD=${wetty_pass}
export COMMENT="Wetty Web Terminal SSH user"

curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/setup-ssh-user.sh | bash
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/web-terminal.sh | bash

echo "[---install-wetty.sh Complete---]"
