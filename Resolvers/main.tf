locals {
  role_class = "stateless"
}
resource "aws_instance" "this" {
  count                = 1
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "c7g.large"
  iam_instance_profile = aws_iam_instance_profile.fdb_instance_profile.name
  subnet_id            = var.private_subnets[0]
  availability_zone    = var.azs[0]
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
    Name = "fdb-resolver-1"
    Role = "resolver"
  }
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
