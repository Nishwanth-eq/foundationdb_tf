# Bcp_obs module - Terraform configuration for FoundationDB backup node

resource "aws_iam_role" "bcp_obs_role" {
  name = "fdb-bcp-obs-role"

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

resource "aws_iam_role_policy" "bcp_obs_policy" {
  name = "fdb-bcp-obs-policy"
  role = aws_iam_role.bcp_obs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "s3:*"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "bcp_obs_profile" {
  name = "fdb-bcp-obs-profile"
  role = aws_iam_role.bcp_obs_role.name
}

resource "aws_security_group" "bcp_obs_sg" {
  name        = "fdb-bcp-obs-sg"
  description = "Security group for FoundationDB backup/observer node"
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

resource "aws_instance" "bcp_obs" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "m7i.large"
  subnet_id               = var.private_subnets[0]
  availability_zone       = var.azs[0]
  iam_instance_profile    = aws_iam_instance_profile.bcp_obs_profile.name
  vpc_security_group_ids  = [aws_security_group.bcp_obs_sg.id]
  associate_public_ip_address = false
  user_data               = base64encode(templatefile("${path.module}/userdata.tpl", {
    fdb_cluster_file = var.fdb_cluster_file
    role_class       = "backup"
    datadog_api_key  = var.datadog_api_key
  }))

  tags = {
    Name = "fdb-bcp-obs"
  }
}

output "bcp_obs_private_ip" {
  value = aws_instance.bcp_obs.private_ip
}
