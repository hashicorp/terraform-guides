#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

local_ipv4="$(echo -e `hostname -I` |awk '{print $1}' | tr -d '[:space:]')"

# stop consul so it can be configured correctly
systemctl stop consul

# clear the consul data directory ready for a fresh start
rm -rf /opt/consul/data/*

# seeing failed nodes listed in consul members with their solo config
# try a 2 min sleep to see if it helps with all instances wiping data
# in a similar time window
#sleep 120

jq ".retry_join += [\"provider=azure tag_name=consul_datacenter tag_value=${consul_datacenter} subscription_id=${auto_join_subscription_id} tenant_id=${auto_join_tenant_id} client_id=${auto_join_client_id} secret_access_key=${auto_join_secret_access_key}\"]" < /etc/consul.d/consul-default.json > /tmp/consul-default.json.tmp

sed -i -e "s/127.0.0.1/$${local_ipv4}/" /tmp/consul-default.json.tmp
mv /tmp/consul-default.json.tmp /etc/consul.d/consul-default.json
chown consul:consul /etc/consul.d/consul-default.json

# add the cluster instance count to the config with jq
jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json > /tmp/consul-server.json.tmp

# change 'leave_on_terminate' to false for server nodes (this is the default but we had it set to true to quickly remove nodes before configuring)
jq ".leave_on_terminate = false" < /etc/consul.d/consul-server.json > /tmp/consul-server.json.tmp

mv /tmp/consul-server.json.tmp /etc/consul.d/consul-server.json
chown consul:consul /etc/consul.d/consul-server.json

# start consul once it is configured correctly
systemctl start consul
