#!/bin/bash

echo "[---Begin quick-start-vault-systemd.sh---]"

echo "Set variables"
LOCAL_IPV4=$(curl -s ${local_ip_url})
CONSUL_CONFIG_FILE=/etc/consul.d/consul-server.json
VAULT_CONFIG_FILE=/etc/vault.d/vault-server.hcl
NOMAD_CONFIG_FILE=/etc/nomad.d/nomad-server.hcl

echo "Configure Consul server"
cat <<CONFIG | sudo tee $CONSUL_CONFIG_FILE
{
  "datacenter": "${name}",
  "advertise_addr": "$LOCAL_IPV4",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "server": true,
  "bootstrap_expect": ${consul_bootstrap},
  "leave_on_terminate": true,
  "retry_join": ["provider=${provider} tag_key=Consul-Auto-Join tag_value=${name}"],
  "encrypt": "${consul_encrypt}",
  "ca_file": "$CONSUL_CACERT_FILE",
  "cert_file": "$CONSUL_CLIENT_CERT_FILE",
  "key_file": "$CONSUL_CLIENT_KEY_FILE",
  "verify_incoming": true,
  "verify_outgoing": true,
  "ports": { "https": 8080 }
}
CONFIG

echo "Update Consul configuration file permissions"
sudo chown consul:consul $CONSUL_CONFIG_FILE

echo "Don't start Consul in -dev mode"
cat <<SWITCHES | sudo tee /etc/consul.d/consul.conf
SWITCHES

echo "Restart Consul"
sudo systemctl restart consul

echo "Configure Vault server"
cat <<CONFIG | sudo tee $VAULT_CONFIG_FILE
# Configure Vault server with TLS disabled and the Consul storage backend: https://www.vaultproject.io/docs/configuration/storage/consul.html
backend "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
CONFIG

echo "Update Vault configuration file permissions"
sudo chown vault:vault $VAULT_CONFIG_FILE

echo "Configure Vault environment variables to point Vault server CLI to local Vault cluster and skip TLS verification on login"
cat <<ENVVARS | sudo tee /etc/profile.d/vault.sh
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_SKIP_VERIFY="true"
ENVVARS

echo "Don't start Vault in -dev mode"
cat <<SWITCHES | sudo tee /etc/vault.d/vault.conf
SWITCHES

echo "Restart Vault"
sudo systemctl restart vault

echo "Configure Nomad server"
cat <<CONFIG | sudo tee $NOMAD_CONFIG_FILE
data_dir     = "/opt/nomad/data"
log_level    = "INFO"
enable_debug = true

consul {
  address        = "127.0.0.1:8500"
  auto_advertise = true

  client_service_name = "nomad-client"
  client_auto_join    = true

  server_service_name = "nomad-server"
  server_auto_join    = true
}

server {
  enabled          = true
  bootstrap_expect = ${nomad_bootstrap}
  heartbeat_grace  = "30s"
}

client {
  enabled         = true
  client_max_port = 15000

  options {
    "docker.cleanup.image"   = "0"
    "driver.raw_exec.enable" = "1"
  }
}
CONFIG

echo "Update Nomad configuration file permissions"
sudo chown nomad:nomad $NOMAD_CONFIG_FILE

echo "Configure Nomad environment variables to point Nomad client CLI to local Nomad cluster and skip TLS verification on login"
cat <<ENVVARS | sudo tee /etc/profile.d/nomad.sh
export NOMAD_ADDR="http://127.0.0.1:4646"
export NOMAD_SKIP_VERIFY="true"
ENVVARS

echo "Don't start Nomad in -dev mode"
cat <<SWITCHES | sudo tee /etc/nomad.d/nomad.conf
SWITCHES

echo "Restart Nomad"
sudo systemctl restart nomad

echo "[---quick-start-vault-systemd.sh Complete---]"
