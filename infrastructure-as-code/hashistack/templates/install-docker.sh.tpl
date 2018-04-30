#!/bin/bash

echo "[---Begin install-docker.sh---]"

echo "Install Docker"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/nomad/scripts/install-docker.sh | bash

echo "[---install-docker.sh Complete---]"
