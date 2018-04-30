#!/bin/bash

echo "[---Begin best-practices-hashistack-systemd.sh---]"

NODE_NAME=$(hostname)
LOCAL_IPV4=$(curl -s ${local_ip_url})
CONSUL_TLS_DIR=/opt/consul/tls
CONSUL_CONFIG_DIR=/etc/consul.d
VAULT_TLS_DIR=/opt/vault/tls
VAULT_CONFIG_DIR=/etc/vault.d
NOMAD_TLS_DIR=/opt/nomad/tls
NOMAD_CONFIG_DIR=/etc/nomad.d

echo "Update resolv.conf"
sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf

echo "Write certs to TLS directories"
cat <<EOF | sudo tee $CONSUL_TLS_DIR/consul-ca.crt $VAULT_TLS_DIR/consul-ca.crt $VAULT_TLS_DIR/vault-ca.crt $NOMAD_TLS_DIR/consul-ca.crt $NOMAD_TLS_DIR/vault-ca.crt $NOMAD_TLS_DIR/nomad-ca.crt
${ca_crt}
EOF
cat <<EOF | sudo tee $CONSUL_TLS_DIR/consul.crt $VAULT_TLS_DIR/consul.crt $VAULT_TLS_DIR/vault.crt $NOMAD_TLS_DIR/consul.crt $NOMAD_TLS_DIR/vault.crt $NOMAD_TLS_DIR/nomad.crt
${leaf_crt}
EOF
cat <<EOF | sudo tee $CONSUL_TLS_DIR/consul.key $VAULT_TLS_DIR/consul.key $VAULT_TLS_DIR/vault.key $NOMAD_TLS_DIR/consul.key $NOMAD_TLS_DIR/vault.key $NOMAD_TLS_DIR/nomad.key
${leaf_key}
EOF

sudo chown -R consul:consul $CONSUL_TLS_DIR $CONSUL_CONFIG_DIR
sudo chown -R vault:vault $VAULT_TLS_DIR $VAULT_CONFIG_DIR
sudo chown -R root:root $NOMAD_TLS_DIR $NOMAD_CONFIG_DIR

echo "Configure HashiStack Consul client"
cat <<CONFIG | sudo tee $CONSUL_CONFIG_DIR/default.json
{
  "datacenter": "${name}",
  "node_name": "$NODE_NAME",
  "data_dir": "/opt/consul/data",
  "log_level": "INFO",
  "advertise_addr": "$LOCAL_IPV4",
  "client_addr": "0.0.0.0",
  "ui": true,
  "server": true,
  "bootstrap_expect": ${consul_bootstrap},
  "leave_on_terminate": true,
  "retry_join": ["provider=${provider} tag_key=Consul-Auto-Join tag_value=${name}"],
  "encrypt": "${consul_encrypt}",
  "encrypt_verify_incoming": true,
  "encrypt_verify_outgoing": true,
  "ca_file": "$CONSUL_TLS_DIR/consul-ca.crt",
  "cert_file": "$CONSUL_TLS_DIR/consul.crt",
  "key_file": "$CONSUL_TLS_DIR/consul.key",
  "verify_incoming": false,
  "verify_incoming_https": false,
  "verify_incoming_rpc": true,
  "verify_outgoing": true,
  "verify_server_hostname": true,
  "ports": {
    "https": 8080
  },
  "addresses": {
    "https": "0.0.0.0"
  }
}
CONFIG

if [ ${consul_override} == true ] || [ ${consul_override} == 1 ]; then
  echo "Add custom Consul client override config"
  cat <<CONFIG | sudo tee $CONSUL_CONFIG_DIR/z-override.json
${consul_config}
CONFIG
fi

echo "Configure Consul environment variables for HTTPS API requests on login"
cat <<PROFILE | sudo tee /etc/profile.d/consul.sh
export CONSUL_ADDR=https://127.0.0.1:8080
export CONSUL_CACERT=$CONSUL_TLS_DIR/consul-ca.crt
export CONSUL_CLIENT_CERT=$CONSUL_TLS_DIR/consul.crt
export CONSUL_CLIENT_KEY=$CONSUL_TLS_DIR/consul.key
PROFILE

echo "Don't start Consul in -dev mode and use SSL"
cat <<ENVVARS | sudo tee $CONSUL_CONFIG_DIR/consul.conf
CONSUL_HTTP_ADDR=127.0.0.1:8080
CONSUL_HTTP_SSL=true
CONSUL_HTTP_SSL_VERIFY=false
ENVVARS

sudo systemctl restart consul

echo "Configure Vault"
cat <<CONFIG | sudo tee $VAULT_CONFIG_DIR/default.hcl
# https://www.vaultproject.io/docs/configuration/index.html
cluster_name = "${name}"
ui           = true

# https://www.vaultproject.io/docs/configuration/storage/consul.html
backend "consul" {
  scheme  = "https"
  address = "127.0.0.1:8080"
  path    = "vault/"
  service = "vault"

  tls_ca_file   = "$VAULT_TLS_DIR/consul-ca.crt"
  tls_cert_file = "$VAULT_TLS_DIR/consul.crt"
  tls_key_file  = "$VAULT_TLS_DIR/consul.key"
}

# https://www.vaultproject.io/docs/configuration/listener/tcp.html
listener "tcp" {
  address = "0.0.0.0:8200"

  tls_client_ca_file = "$VAULT_TLS_DIR/vault-ca.crt"
  tls_cert_file      = "$VAULT_TLS_DIR/vault.crt"
  tls_key_file       = "$VAULT_TLS_DIR/vault.key"

  tls_require_and_verify_client_cert = false
  tls_disable_client_certs           = true
}
CONFIG

if [ ${vault_override} == true ] || [ ${vault_override} == 1 ]; then
  echo "Add custom Vault server override config"
  cat <<CONFIG | sudo tee $VAULT_CONFIG_DIR/z-override.hcl
${vault_config}
CONFIG
fi

echo "Configure Vault environment variables to point Vault server CLI to local Vault cluster"
cat <<PROFILE | sudo tee /etc/profile.d/vault.sh
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_SKIP_VERIFY=false
export VAULT_CACERT=$VAULT_TLS_DIR/vault-ca.crt
export VAULT_CLIENT_CERT=$VAULT_TLS_DIR/vault.crt
export VAULT_CLIENT_KEY=$VAULT_TLS_DIR/vault.key
PROFILE

echo "Don't start Vault in -dev mode"
echo '' | sudo tee $VAULT_CONFIG_DIR/vault.conf

sudo systemctl restart vault

echo "Configure Nomad"
cat <<CONFIG | sudo tee $NOMAD_CONFIG_DIR/default.hcl
# https://www.nomadproject.io/docs/agent/configuration/index.html
region     = "global"
name       = "$NODE_NAME"
log_level  = "INFO"
data_dir   = "/opt/nomad/data"
bind_addr  = "0.0.0.0"

# https://www.nomadproject.io/docs/agent/configuration/index.html#advertise
advertise {
  http = "$LOCAL_IPV4:4646"
  rpc  = "$LOCAL_IPV4:4647"
  serf = "$LOCAL_IPV4:4648"
}

# https://www.nomadproject.io/docs/agent/configuration/server.html
server {
  enabled          = true
  bootstrap_expect = ${nomad_bootstrap}
  encrypt          = "${nomad_encrypt}"
}

# https://www.nomadproject.io/docs/agent/configuration/client.html
client {
  enabled = true
}

# https://www.nomadproject.io/docs/agent/configuration/consul.html
consul {
  address              = "127.0.0.1:8080"
  auto_advertise       = true
  checks_use_advertise = true

  server_service_name = "nomad"
  server_auto_join    = true

  client_service_name = "nomad-client"
  client_auto_join    = true

  ssl        = true
  verify_ssl = true
  ca_file    = "$NOMAD_TLS_DIR/consul-ca.crt"
  cert_file  = "$NOMAD_TLS_DIR/consul.crt"
  key_file   = "$NOMAD_TLS_DIR/consul.key"
}

# https://www.nomadproject.io/docs/agent/configuration/tls.html
tls {
  http = true
  rpc  = true

  ca_file   = "$NOMAD_TLS_DIR/nomad-ca.crt"
  cert_file = "$NOMAD_TLS_DIR/nomad.crt"
  key_file  = "$NOMAD_TLS_DIR/nomad.key"

  verify_server_hostname = true
  verify_https_client    = false
}
CONFIG

if [ ${nomad_override} == true ] || [ ${nomad_override} == 1 ]; then
  echo "Add custom Nomad client override config"
  cat <<CONFIG | sudo tee $NOMAD_CONFIG_DIR/z-override.hcl
${nomad_config}
CONFIG
fi

echo "Configure Nomad environment variables to point Nomad client CLI to remote Nomad cluster & set TLS certs on login"
cat <<PROFILE | sudo tee /etc/profile.d/nomad.sh
export NOMAD_ADDR=https://127.0.0.1:4646
export NOMAD_SKIP_VERIFY=false
export NOMAD_CACERT=$NOMAD_TLS_DIR/nomad-ca.crt
export NOMAD_CLIENT_CERT=$NOMAD_TLS_DIR/nomad.crt
export NOMAD_CLIENT_KEY=$NOMAD_TLS_DIR/nomad.key
PROFILE

echo "Don't start Nomad in -dev mode"
echo '' | sudo tee $NOMAD_CONFIG_DIR/nomad.conf

sudo systemctl restart nomad

echo "[---best-practices-hashistack-systemd.sh Complete---]"
