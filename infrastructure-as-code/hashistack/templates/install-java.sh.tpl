#!/bin/bash

echo "[---Begin install-java.sh---]"

echo "Install Java"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/nomad/scripts/install-java.sh | bash

echo "[---install-java.sh Complete---]"
