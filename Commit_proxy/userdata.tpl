#!/bin/bash
set -e

# Update system
apt-get update
apt-get install -y curl wget gnupg lsb-release

# Install FoundationDB
wget https://www.foundationdb.org/downloads/7.4.5/ubuntu/foundationdb-7.4.5-1_amd64.deb
dpkg -i foundationdb-7.4.5-1_amd64.deb || apt-get install -f -y

# Create FoundationDB directories
mkdir -p /var/log/foundationdb
mkdir -p /var/lib/foundationdb
chown -R foundationdb:foundationdb /var/log/foundationdb /var/lib/foundationdb

# Write the fdb.cluster file
echo '${fdb_cluster_file}' > /etc/foundationdb/fdb.cluster
chown foundationdb:foundationdb /etc/foundationdb/fdb.cluster
chmod 644 /etc/foundationdb/fdb.cluster

# Update foundationdb.conf for role
cat > /etc/foundationdb/foundationdb.conf <<'EOFCONF'
[general]
cluster_file = /etc/foundationdb/fdb.cluster

[${role_class}]
class = ${role_class}
EOFCONF

chown foundationdb:foundationdb /etc/foundationdb/foundationdb.conf
chmod 644 /etc/foundationdb/foundationdb.conf

# Start FoundationDB
systemctl restart foundationdb
systemctl enable foundationdb

# Wait for FDB to be ready
sleep 10
