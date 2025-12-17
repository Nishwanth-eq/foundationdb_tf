locals {
  role_class = "tlog"
}
resource "aws_instance" "this" {
  count                = 4
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "m7i.large"
  iam_instance_profile = aws_iam_instance_profile.fdb_instance_profile.name
  subnet_id            = var.private_subnets[count.index % 3]
  availability_zone    = var.azs[count.index % 3]
  security_groups      = [aws_security_group.fdb.id]
  user_data = base64encode(templatefile("${path.module}/userdata.tpl", {
    fdb_cluster_file = var.fdb_cluster_file
    role_class       = local.role_class
  }))
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  tags = {
    Name = "fdb-tlog-${count.index + 1}"
    Role = "tlog"
  }
}
resource "aws_ebs_volume" "tlog_io2" {
  count             = 4
  availability_zone = var.azs[count.index % 3]
  size              = 500
  type              = "io2"
  iops              = 16000
  throughput        = 1000
  tags = {
    Name = "fdb-tlog-io2-${count.index + 1}"
  }
}
resource "aws_volume_attachment" "tlog_io2" {
  count           = 4
  device_name     = "/dev/sdf"
  volume_id       = aws_ebs_volume.tlog_io2[count.index].id
  instance_id     = aws_instance.this[count.index].id
  force_detach    = true
}
output "private_ips" {
  value = aws_instance.this[*].private_ip
}
output "instance_ids" {
  value = aws_instance.this[*].id
}
resource "aws_security_group" "fdb" {
  vpc_id = var.vpc_id
  name   = "fdb-sg-${local.role_class}"
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "tcp"variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "fdb_cluster_file" {
  type = string
}

variable "datadog_api_key" {
  type      = string
  default   = ""
  sensitive = true
}
    self        = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_iam_instance_profile" "fdb_instance_profile" {
  name = "fdb-instance-profile-${local.role_class}"
  role = aws_iam_role.fdb_role.name
}
resource "aws_iam_role" "fdb_role" {
  name = "fdb-role-${local.role_class}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "fdb_policy" {
  role       = aws_iam_role.fdb_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
