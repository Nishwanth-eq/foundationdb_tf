#!/bin/bash
set -e

apt-get update -y
apt-get install -y wget gnupg lsb-release curl

wget -q https://www.foundationdb.org/downloads/${fdb_version}/ubuntu/installers/foundationdb-clients_${fdb_version}-1_amd64.deb
wget -q https://www.foundationdb.org/downloads/${fdb_version}/ubuntu/installers/foundationdb-server_${fdb_version}-1_amd64.deb
dpkg -i foundationdb-*.deb

mkdir -p ${datadir} ${logdir}
chown foundationdb:foundationdb ${datadir} ${logdir}

cat > /etc/foundationdb/foundationdb.conf <<EOF
[general]
cluster-file = /etc/foundationdb/fdb.cluster
restart-delay = 60

[${class}]
public-address = $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):4500
listen-address = 0.0.0.0:4500
datadir = ${datadir}
logdir  = ${logdir}
zoneid  = ${zoneid}
EOF

cat > /etc/foundationdb/fdb.cluster <<EOF
${fdb_cluster_file}
EOF

chown foundationdb:foundationdb /etc/foundationdb/fdb.cluster

systemctl enable foundationdb
systemctl start foundationdb
