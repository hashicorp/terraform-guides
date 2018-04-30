#!/bin/bash

echo "[---Begin install-consul-systemd.sh---]"

echo "Setup Consul user"
export GROUP=consul
export USER=consul
export COMMENT=Consul
export HOME=/srv/consul
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/setup-user.sh | bash

echo "Install Consul"
export VERSION=${consul_version}
export URL=${consul_url}
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/scripts/install-consul.sh | bash

echo "Install Consul Systemd"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/scripts/install-consul-systemd.sh | bash

echo "Cleanup install files"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/cleanup.sh | bash

echo "Set variables"
CONSUL_CONFIG_FILE=/etc/consul.d/default.json
CONSUL_CONFIG_OVERRIDE_FILE=/etc/consul.d/z-override.json
NODE_NAME=$(hostname)

echo "Minimal configuration for Consul UI"
cat <<CONFIG | sudo tee $CONSUL_CONFIG_FILE
{
  "datacenter": "${name}",
  "node_name": "$NODE_NAME",
  "log_level": "INFO",
  "client_addr": "0.0.0.0",
  "ui": true
}
CONFIG

echo "Update Consul configuration file permissions"
sudo chown consul:consul $CONSUL_CONFIG_FILE

if [ ${consul_override} == true ] || [ ${consul_override} == 1 ]; then
  echo "Add custom Consul server override config"
  cat <<CONFIG | sudo tee $CONSUL_CONFIG_OVERRIDE_FILE
${consul_config}
CONFIG

  echo "Update Consul configuration override file permissions"
  sudo chown consul:consul $CONSUL_CONFIG_OVERRIDE_FILE
fi

echo "Restart Consul"
sudo systemctl restart consul

echo "[---install-consul-systemd.sh Complete---]"
