#!/bin/bash

echo "[---Begin install-consul-systemd.sh---]"

echo "Download scripts"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/shared/scripts/download-guides-configuration.sh | sudo bash

echo "Run base script"
bash /tmp/shared/scripts/base.sh

echo "Setup Consul user"
export GROUP=consul
export USER=consul
export COMMENT=Consul
export HOME=/srv/consul
bash /tmp/shared/scripts/setup-user.sh

echo "Install Consul"
export VERSION=${consul_version}
export URL=${consul_url}
bash /tmp/consul/scripts/install-consul.sh

echo "Install Consul Systemd"
bash /tmp/consul/scripts/install-consul-systemd.sh

echo "Cleanup install files"
sudo rm -rf /tmp/*
sudo rm -rf /tmp/.git*

echo "[---install-consul-systemd.sh Complete---]"
