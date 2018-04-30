#!/bin/bash

echo "[---Begin install-base.sh---]"

echo "Wait for system to be ready"
sleep 10

echo "Run base script"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/master/shared/scripts/base.sh | bash

echo "[---install-base.sh Complete---]"
