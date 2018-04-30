#!/bin/bash

echo "[---Begin best-practices-bastion-systemd.sh---]"

NODE_NAME=$(hostname)
LOCAL_IPV4=$(curl -s ${local_ip_url})
CONSUL_TLS_DIR=/opt/consul/tls
CONSUL_CONFIG_DIR=/etc/consul.d
VAULT_TLS_DIR=/opt/vault/tls
NOMAD_TLS_DIR=/opt/nomad/tls

echo "Update resolv.conf"
sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf

echo "Create TLS dirs for certs"
sudo mkdir -pm 0755 $CONSUL_TLS_DIR $VAULT_TLS_DIR $NOMAD_TLS_DIR

echo "Write certs to TLS directories"
cat <<EOF | sudo tee $CONSUL_TLS_DIR/consul-ca.crt $VAULT_TLS_DIR/vault-ca.crt $NOMAD_TLS_DIR/nomad-ca.crt
${ca_crt}
EOF
cat <<EOF | sudo tee $CONSUL_TLS_DIR/consul.crt $VAULT_TLS_DIR/vault.crt $NOMAD_TLS_DIR/nomad.crt
${leaf_crt}
EOF
cat <<EOF | sudo tee $CONSUL_TLS_DIR/consul.key $VAULT_TLS_DIR/vault.key $NOMAD_TLS_DIR/nomad.key
${leaf_key}
EOF

sudo chown -R consul:consul $CONSUL_TLS_DIR $CONSUL_CONFIG_DIR
sudo chown -R vault:vault $VAULT_TLS_DIR
sudo chown -R root:root $NOMAD_TLS_DIR

echo "Configure Bastion Consul client"
cat <<CONFIG | sudo tee $CONSUL_CONFIG_DIR/default.json
{
  "datacenter": "${name}",
  "node_name": "$NODE_NAME",
  "data_dir": "/opt/consul/data",
  "log_level": "INFO",
  "advertise_addr": "$LOCAL_IPV4",
  "client_addr": "0.0.0.0",
  "ui": true,
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

echo "Configure Vault environment variables to point Vault client CLI to remote Vault cluster & set TLS certs on login"
cat <<PROFILE | sudo tee /etc/profile.d/vault.sh
export VAULT_ADDR=https://vault.service.consul:8200
export VAULT_SKIP_VERIFY=false
export VAULT_CACERT=$VAULT_TLS_DIR/vault-ca.crt
export VAULT_CLIENT_CERT=$VAULT_TLS_DIR/vault.crt
export VAULT_CLIENT_KEY=$VAULT_TLS_DIR/vault.key
PROFILE

echo "Don't start Vault in -dev mode & stop Vault now that the CLI is pointing to a live Vault cluster"
echo '' | sudo tee /etc/vault.d/vault.conf
sudo systemctl stop vault

echo "Configure Nomad environment variables to point Nomad client CLI to remote Nomad cluster & set TLS certs on login"
cat <<PROFILE | sudo tee /etc/profile.d/nomad.sh
export NOMAD_ADDR=https://nomad.service.consul:4646
export NOMAD_SKIP_VERIFY=false
export NOMAD_CACERT=$NOMAD_TLS_DIR/nomad-ca.crt
export NOMAD_CLIENT_CERT=$NOMAD_TLS_DIR/nomad.crt
export NOMAD_CLIENT_KEY=$NOMAD_TLS_DIR/nomad.key
PROFILE

echo "Don't start Nomad in -dev mode stop Nomad now that the CLI is pointing to a live Nomad cluster"
echo '' | sudo tee /etc/nomad.d/nomad.conf
sudo systemctl stop nomad

echo "[---best-practices-bastion-systemd.sh Complete---]"
