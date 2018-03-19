#!/bin/bash

echo "[---Begin install-consul-systemd.sh---]"

echo "Run base script"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/shared/scripts/base.sh | bash

echo "Setup Consul user"
export GROUP=consul
export USER=consul
export COMMENT=Consul
export HOME=/srv/consul
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/shared/scripts/setup-user.sh | bash

echo "Install Consul"
export VERSION=${consul_version}
export URL=${consul_url}
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/consul/scripts/install-consul.sh | bash

echo "Install Consul Systemd"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/consul/scripts/install-consul-systemd.sh | bash

echo "Cleanup install files"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/shared/scripts/cleanup.sh | bash

echo "[---install-consul-systemd.sh Complete---]"
