#!/bin/bash

echo "[---Begin best-practices-hashistack-systemd.sh---]"

echo "Update resolv.conf"
sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf

echo "Set variables"
LOCAL_IPV4=$(curl -s ${local_ip_url})
CONSUL_TLS_FILE=/opt/consul/tls
CONSUL_CACERT_FILE="$CONSUL_TLS_FILE/ca.crt"
CONSUL_CLIENT_CERT_FILE="$CONSUL_TLS_FILE/consul.crt"
CONSUL_CLIENT_KEY_FILE="$CONSUL_TLS_FILE/consul.key"
CONSUL_CONFIG_FILE=/etc/consul.d/consul-server.json
VAULT_TLS_FILE=/opt/vault/tls
VAULT_CACERT_FILE="$VAULT_TLS_FILE/ca.crt"
VAULT_CLIENT_CERT_FILE="$VAULT_TLS_FILE/vault.crt"
VAULT_CLIENT_KEY_FILE="$VAULT_TLS_FILE/vault.key"
VAULT_CONFIG_FILE=/etc/vault.d/vault-server.hcl
NOMAD_TLS_FILE=/opt/nomad/tls
NOMAD_CACERT_FILE="$NOMAD_TLS_FILE/ca.crt"
NOMAD_CLIENT_CERT_FILE="$NOMAD_TLS_FILE/nomad.crt"
NOMAD_CLIENT_KEY_FILE="$NOMAD_TLS_FILE/nomad.key"
NOMAD_CONFIG_FILE=/etc/nomad.d/nomad-server.hcl

echo "Create TLS dir for Consul certs"
sudo mkdir -pm 0755 $CONSUL_TLS_FILE

echo "Write Consul CA certificate to $CONSUL_CACERT_FILE"
cat <<EOF | sudo tee $CONSUL_CACERT_FILE
${consul_ca_crt}
EOF

echo "Write Consul certificate to $CONSUL_CLIENT_CERT_FILE"
cat <<EOF | sudo tee $CONSUL_CLIENT_CERT_FILE
${consul_leaf_crt}
EOF

echo "Write Consul certificate key to $CONSUL_CLIENT_KEY_FILE"
cat <<EOF | sudo tee $CONSUL_CLIENT_KEY_FILE
${consul_leaf_key}
EOF

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

echo "Update Consul configuration & certificates file owner"
sudo chown -R consul:consul $CONSUL_CONFIG_FILE $CONSUL_TLS_FILE

echo "Don't start Consul in -dev mode"
cat <<SWITCHES | sudo tee /etc/consul.d/consul.conf
SWITCHES

echo "Restart Consul"
sudo systemctl restart consul

echo "Create tls dir for Vault certs"
sudo mkdir -pm 0755 $VAULT_TLS_FILE

echo "Write Vault CA certificate to $VAULT_CACERT_FILE"
cat <<EOF | sudo tee $VAULT_CACERT_FILE
${vault_ca_crt}
EOF

echo "Write Vault certificate to $VAULT_CLIENT_CERT_FILE"
cat <<EOF | sudo tee $VAULT_CLIENT_CERT_FILE
${vault_leaf_crt}
EOF

echo "Write Vault certificate key to $VAULT_CLIENT_KEY_FILE"
cat <<EOF | sudo tee $VAULT_CLIENT_KEY_FILE
${vault_leaf_key}
EOF

echo "Configure Vault server"
cat <<CONFIG | sudo tee $VAULT_CONFIG_FILE
# Configure Vault server with TLS and the Consul storage backend: https://www.vaultproject.io/docs/configuration/storage/consul.html
backend "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"

  tls_ca_file   = "$CONSUL_CACERT_FILE"
  tls_cert_file = "$CONSUL_CLIENT_CERT_FILE"
  tls_key_file  = "$CONSUL_CLIENT_KEY_FILE"
}

# https://www.vaultproject.io/docs/configuration/listener/tcp.html
listener "tcp" {
  address = "0.0.0.0:8200"

  tls_client_ca_file = "$VAULT_CACERT_FILE"
  tls_cert_file      = "$VAULT_CLIENT_CERT_FILE"
  tls_key_file       = "$VAULT_CLIENT_KEY_FILE"

  tls_require_and_verify_client_cert = true
}
CONFIG

echo "Update Vault configuration & certificates file owner"
sudo chown -R vault:vault $VAULT_CONFIG_FILE $VAULT_TLS_FILE

echo "Configure Vault environment variables to point Vault server CLI to local Vault cluster"
cat <<ENVVARS | sudo tee /etc/profile.d/vault.sh
export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_CACERT="$VAULT_CACERT_FILE"
export VAULT_CLIENT_CERT="$VAULT_CLIENT_CERT_FILE"
export VAULT_CLIENT_KEY="$VAULT_CLIENT_KEY_FILE"
ENVVARS

echo "Don't start Vault in -dev mode"
cat <<SWITCHES | sudo tee /etc/vault.d/vault.conf
SWITCHES

echo "Restart Vault"
sudo systemctl restart vault

echo "Create tls dir for Nomad certs"
sudo mkdir -pm 0755 $NOMAD_TLS_FILE

echo "Write Nomad CA certificate to $NOMAD_CACERT_FILE"
cat <<EOF | sudo tee $NOMAD_CACERT_FILE
${nomad_ca_crt}
EOF

echo "Write Nomad certificate to $NOMAD_CLIENT_CERT_FILE"
cat <<EOF | sudo tee $NOMAD_CLIENT_CERT_FILE
${nomad_leaf_crt}
EOF

echo "Write Nomad certificate key to $NOMAD_CLIENT_KEY_FILE"
cat <<EOF | sudo tee $NOMAD_CLIENT_KEY_FILE
${nomad_leaf_key}
EOF

echo "Configure Nomad server"
cat <<CONFIG | sudo tee $NOMAD_CONFIG_FILE
data_dir  = "/opt/nomad/data"
log_level = "INFO"

server {
  enabled          = true
  bootstrap_expect = ${nomad_bootstrap}
  heartbeat_grace  = "30s"
  encrypt          = "${nomad_encrypt}"
}

client {
  enabled         = true
  client_max_port = 15000

  options {
    "docker.cleanup.image"   = "0"
    "driver.raw_exec.enable" = "1"
  }
}

tls {
  http = true
  rpc  = true

  ca_file   = "$NOMAD_CACERT_FILE"
  cert_file = "$NOMAD_CLIENT_CERT_FILE"
  key_file  = "$NOMAD_CLIENT_KEY_FILE"

  verify_server_hostname = true
  verify_https_client    = true
}

consul {
  address        = "127.0.0.1:8500"
  auto_advertise = true

  client_service_name = "nomad-client"
  client_auto_join    = true

  server_service_name = "nomad-server"
  server_auto_join    = true

  verify_ssl = true
  ca_file    = "$CONSUL_CACERT_FILE"
  cert_file  = "$CONSUL_CLIENT_CERT_FILE"
  key_file   = "$CONSUL_CLIENT_KEY_FILE"
}

vault {
  enabled = true
  address = "127.0.0.1:8200"

  ca_file    = "$VAULT_CACERT_FILE"
  cert_file  = "$VAULT_CLIENT_CERT_FILE"
  key_file   = "$VAULT_CLIENT_KEY_FILE"
}
CONFIG

echo "Update Nomad configuration & certificates file owner"
sudo chown -R nomad:nomad $NOMAD_CONFIG_FILE $NOMAD_TLS_FILE

echo "Configure Nomad environment variables to point Nomad client CLI to remote Nomad cluster & set TLS certs on login"
cat <<ENVVARS | sudo tee /etc/profile.d/nomad.sh
export NOMAD_ADDR="https://127.0.0.1:4646"
export NOMAD_CACERT="$NOMAD_CACERT_FILE"
export NOMAD_CLIENT_CERT="$NOMAD_CLIENT_CERT_FILE"
export NOMAD_CLIENT_KEY="$NOMAD_CLIENT_KEY_FILE"
ENVVARS

echo "Don't start Nomad in -dev mode"
cat <<SWITCHES | sudo tee /etc/nomad.d/nomad.conf
SWITCHES

echo "Restart Nomad"
sudo systemctl restart nomad

echo "[---best-practices-hashistack-systemd.sh Complete---]"
