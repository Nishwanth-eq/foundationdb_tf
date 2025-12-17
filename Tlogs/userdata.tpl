#!/bin/bash
set -e
apt-get update
apt-get install -y curl wget gnupg lsb-release xfsprogs
wget https://www.foundationdb.org/downloads/7.4.5/ubuntu/foundationdb-7.4.5-1_amd64.deb
dpkg -i foundationdb-7.4.5-1_amd64.deb || apt-get install -f -y
mkdir -p /var/log/foundationdb /var/lib/foundationdb
chown -R foundationdb:foundationdb /var/log/foundationdb /var/lib/foundationdb
echo '${fdb_cluster_file}' > /etc/foundationdb/fdb.cluster
chown foundationdb:foundationdb /etc/foundationdb/fdb.cluster
chmod 644 /etc/foundationdb/fdb.cluster
wait_for_device() {
  for i in {1..30}; do [ -b /dev/xvdf ] && return 0; sleep 1; done; return 1
}
wait_for_device || exit 1
mkfs.xfs -f /dev/xvdf
mkdir -p /mnt/tlog-io2
mount /dev/xvdf /mnt/tlog-io2
chown foundationdb:foundationdb /mnt/tlog-io2
chmod 750 /mnt/tlog-io2
echo '/dev/xvdf /mnt/tlog-io2 xfs defaults 0 0' >> /etc/fstab
cat > /etc/foundationdb/foundationdb.conf <<'EOFCONF'
[general]
cluster_file = /etc/foundationdb/fdb.cluster
[${role_class}]
class = ${role_class}
logdir = /mnt/tlog-io2/log
datadir = /mnt/tlog-io2/data
EOFCONF
chown foundationdb:foundationdb /etc/foundationdb/foundationdb.conf
chmod 644 /etc/foundationdb/foundationdb.conf
mkdir -p /mnt/tlog-io2/{log,data}
chown -R foundationdb:foundationdb /mnt/tlog-io2/{log,data}
systemctl restart foundationdb
systemctl enable foundationdb
sleep 10
