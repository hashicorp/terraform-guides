#!/bin/bash

echo "[---Begin install-nomad-systemd.sh---]"

echo "Install Nomad"
export VERSION=${nomad_version}
export URL=${nomad_url}
export USER=root
export GROUP=root
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/nomad/scripts/install-nomad.sh | bash

echo "Install Nomad Systemd"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/nomad/scripts/install-nomad-systemd.sh | bash

echo "Cleanup install files"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/cleanup.sh | bash

echo "Set variables"
NOMAD_CONFIG_FILE=/etc/nomad.d/default.hcl
NOMAD_CONFIG_OVERRIDE_FILE=/etc/nomad.d/z-override.hcl
NODE_NAME=$(hostname)
LOCAL_IPV4=$(curl -s ${local_ip_url})

echo "Minimal configuration for Nomad UI"
cat <<CONFIG | sudo tee $NOMAD_CONFIG_FILE
region    = "${name}"
name      = "$NODE_NAME"
log_level = "INFO"
bind_addr = "0.0.0.0"

advertise {
  http = "$LOCAL_IPV4:4646"
  rpc  = "$LOCAL_IPV4:4647"
  serf = "$LOCAL_IPV4:4648"
}
CONFIG

echo "Update Nomad configuration file permissions"
sudo chown root:root $NOMAD_CONFIG_FILE

if [ ${nomad_override} == true ] || [ ${nomad_override} == 1 ]; then
  echo "Add custom Nomad server override config"
  cat <<CONFIG | sudo tee $NOMAD_CONFIG_OVERRIDE_FILE
${nomad_config}
CONFIG

  echo "Update Nomad configuration override file permissions"
  sudo chown root:root $NOMAD_CONFIG_OVERRIDE_FILE
fi

echo "Restart Nomad"
sudo systemctl restart nomad

echo "[---install-nomad-systemd.sh Complete---]"
