# Storage module - Terraform configuration for FoundationDB storage nodes

resource "aws_iam_role" "storage_role" {
  name = "fdb-storage-role"

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

resource "aws_iam_role_policy" "storage_policy" {
  name = "fdb-storage-policy"
  role = aws_iam_role.storage_role.id

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

resource "aws_iam_instance_profile" "storage_profile" {
  name = "fdb-storage-profile"
  role = aws_iam_role.storage_role.name
}

resource "aws_security_group" "storage_sg" {
  name        = "fdb-storage-sg"
  description = "Security group for FoundationDB storage nodes"
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

resource "aws_instance" "storage" {
  count                    = 3
  ami                      = data.aws_ami.ubuntu.id
  instance_type            = "m7i.large"
  subnet_id                = var.private_subnets[count.index]
  availability_zone        = var.azs[count.index]
  iam_instance_profile     = aws_iam_instance_profile.storage_profile.name
  vpc_security_group_ids   = [aws_security_group.storage_sg.id]
  associate_public_ip_address = false
  user_data                = base64encode(templatefile("${path.module}/userdata.tpl", {
    fdb_cluster_file = var.fdb_cluster_file
    role_class       = "storage"
    datadog_api_key  = var.datadog_api_key
  }))

  tags = {
    Name = "fdb-storage-${count.index}"
  }
}

resource "aws_ebs_volume" "storage_data" {
  count             = 3
  availability_zone = var.azs[count.index]
  size              = 2000
  type              = "gp3"
  iops              = 3000
  throughput        = 125

  tags = {
    Name = "fdb-storage-data-${count.index}"
  }
}

resource "aws_volume_attachment" "storage_data" {
  count           = 3
  device_name     = "/dev/sdf"
  volume_id       = aws_ebs_volume.storage_data[count.index].id
  instance_id     = aws_instance.storage[count.index].id
}

output "storage_private_ips" {
  value = aws_instance.storage[*].private_ip
}
