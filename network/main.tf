variable "vpc_cidr" {}
variable "azs" { type = list(string) }
variable "cluster_id" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "${var.cluster_id}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs

  private_subnets   = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  enable_nat_gateway = true
}

resource "aws_security_group" "fdb" {
  name_prefix = "${var.cluster_id}-fdb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 4500
    to_port   = 4500
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "private_subnet_ids" { value = module.vpc.private_subnets }
output "fdb_sg_id"          { value = aws_security_group.fdb.id }
output "vpc_id"             { value = module.vpc.vpc_id }
