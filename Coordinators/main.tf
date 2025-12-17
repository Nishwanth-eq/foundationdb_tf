locals { role_class = "stateless" }

resource "aws_instance" "this" {
  count         = var.count
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.sg_id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/userdata.tpl", {
    class           = local.role_class
    zoneid          = var.azs[count.index % length(var.azs)]
    datadir         = "/var/lib/foundationdb/data"
    logdir          = "/var/lib/foundationdb/logs"
    fdb_version     = var.fdb_version
    fdb_cluster_file = var.fdb_cluster_file
  })

  tags = {
    Name       = "fdb-coordinator-${count.index + 1}"
    Role       = "coordinator"
    Class      = local.role_class
    ZoneId     = var.azs[count.index % length(var.azs)]
    ClusterId  = var.cluster_id
  }
}

output "private_ips" {
  value = aws_instance.this[*].private_ip
}
