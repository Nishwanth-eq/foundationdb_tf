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

# Wait for data volume to be attached
while [ ! -e /dev/xvdf ]; do
  echo "Waiting for /dev/xvdf..."
  sleep 5
done

# Format and mount data volume
mkfs.xfs /dev/xvdf
mkdir -p /mnt/storage-gp3
mount /dev/xvdf /mnt/storage-gp3

# Add to fstab
echo "/dev/xvdf /mnt/storage-gp3 xfs defaults,nofail 0 2" >> /etc/fstab

# Create data and log directories
mkdir -p /mnt/storage-gp3/data /mnt/storage-gp3/log
chown -R foundationdb:foundationdb /mnt/storage-gp3

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
logdir = /mnt/storage-gp3/log
datadir = /mnt/storage-gp3/data
classType = ${role_class}
CONF
chown foundationdb:foundationdb /etc/foundationdb/foundationdb.conf

# Start FoundationDB service
systemctl restart foundationdb
systemctl enable foundationdb

echo "FoundationDB storage node initialized successfully"
