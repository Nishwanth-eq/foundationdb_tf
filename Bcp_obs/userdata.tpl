#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get install -y curl wget unzip sudo

# Install AWS CLI
wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Download and install FoundationDB
wget https://github.com/apple/foundationdb/releases/download/7.1.27/foundationdb-clients_7.1.27-1_amd64.deb
wget https://github.com/apple/foundationdb/releases/download/7.1.27/foundationdb-server_7.1.27-1_amd64.deb
dpkg -i foundationdb-clients_7.1.27-1_amd64.deb
dpkg -i foundationdb-server_7.1.27-1_amd64.deb

# Write cluster file
cat > /etc/foundationdb/fdb.cluster <<EOF
${fdb_cluster_file}
EOF
chown foundationdb:foundationdb /etc/foundationdb/fdb.cluster

# Configure FoundationDB
cat > /etc/foundationdb/foundationdb.conf <<'CONF'
[general]
cluster_file = /etc/foundationdb/fdb.cluster
[fdbserver]
command = /usr/lib/foundationdb/fdbserver
machine_id = $(hostname)
logdir = /var/log/foundationdb
datadir = /var/lib/foundationdb/data
classType = ${role_class}
CONF
chown foundationdb:foundationdb /etc/foundationdb/foundationdb.conf

# Install and configure Datadog agent if API key provided
if [ -n "${datadog_api_key}" ]; then
  DD_AGENT_MAJOR_VERSION=7 DD_API_KEY="${datadog_api_key}" DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
  systemctl restart datadog-agent
fi

# Start FoundationDB service
systemctl restart foundationdb
systemctl enable foundationdb

echo "FoundationDB backup/observer node initialized successfully"
