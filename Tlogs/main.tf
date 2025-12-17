# Tlogs module - Terraform configuration for FoundationDB transaction logs

resource "aws_iam_role" "tlogs_role" {
  name = "fdb-tlogs-role"

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

resource "aws_iam_role_policy" "tlogs_policy" {
  name = "fdb-tlogs-policy"
  role = aws_iam_role.tlogs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "tlogs_profile" {
  name = "fdb-tlogs-profile"
  role = aws_iam_role.tlogs_role.name
}

resource "aws_security_group" "tlogs_sg" {
  name        = "fdb-tlogs-sg"
  description = "Security group for FoundationDB transaction log nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tlogs" {
  count                    = var.instance_count
  ami                      = data.aws_ami.ubuntu.id
  instance_type            = "m7i.large"
  subnet_id                = var.private_subnets[count.index % 3]
  availability_zone        = var.azs[count.index % 3]
  iam_instance_profile     = aws_iam_instance_profile.tlogs_profile.name
  vpc_security_group_ids   = [aws_security_group.tlogs_sg.id]
  associate_public_ip_address = false
  user_data                = base64encode(templatefile("${path.module}/userdata.tpl", {
    fdb_cluster_file = var.fdb_cluster_file
    role_class       = "tlog"
    datadog_api_key  = var.datadog_api_key
  }))

  tags = {
    Name = "fdb-tlogs-${count.index}"
  }
}

resource "aws_ebs_volume" "tlogs_io2" {
  count             = 4
  availability_zone = var.azs[count.index % 3]
  size              = 500
  type              = "io2"
  iops              = 16000
  throughput        = 1000

  tags = {
    Name = "fdb-tlog-io2-${count.index}"
  }
}

resource "aws_volume_attachment" "tlogs_io2" {
  count           = 4
  device_name     = "/dev/sdf"
  volume_id       = aws_ebs_volume.tlogs_io2[count.index].id
  instance_id     = aws_instance.tlogs[count.index].id
}

output "tlogs_private_ips" {
  value = aws_instance.tlogs[*].private_ip
}
