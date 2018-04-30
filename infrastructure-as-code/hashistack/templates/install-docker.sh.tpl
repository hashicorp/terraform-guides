#!/bin/bash

echo "[---Begin install-docker.sh---]"

echo "Install Docker"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/nomad/scripts/install-docker.sh | bash

echo "[---install-docker.sh Complete---]"
