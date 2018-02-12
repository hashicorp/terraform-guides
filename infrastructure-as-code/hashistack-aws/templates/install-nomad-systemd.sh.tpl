#!/bin/bash

echo "[---Begin install-nomad-systemd.sh---]"

echo "Download scripts"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/shared/scripts/download-guides-configuration.sh | sudo bash

echo "Run base script"
bash /tmp/shared/scripts/base.sh

echo "Setup Nomad user"
export GROUP=nomad
export USER=nomad
export COMMENT=Nomad
export HOME=/srv/nomad
bash /tmp/shared/scripts/setup-user.sh

echo "Install Nomad"
export VERSION=${nomad_version}
export URL=${nomad_url}
bash /tmp/nomad/scripts/install-nomad.sh

echo "Install Nomad Systemd"
bash /tmp/nomad/scripts/install-nomad-systemd.sh

echo "Install Docker"
bash /tmp/nomad/scripts/install-docker.sh

echo "Install Oracle JDK"
bash /tmp/nomad/scripts/install-oracle-jdk.sh

echo "Cleanup install files"
sudo rm -rf /tmp/*
sudo rm -rf /tmp/.git*

echo "[---install-nomad-systemd.sh Complete---]"
