terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source     = "./network"
  vpc_cidr   = var.vpc_cidr
  azs        = var.azs
  cluster_id = var.cluster_id
}

# Coordinators first (needed to build fdb.cluster)
module "coordinators" {
  source          = "./Coordinators"
  ami_id          = data.aws_ami.ubuntu.id
  subnet_ids      = module.network.private_subnet_ids
  sg_id           = module.network.fdb_sg_id
  instance_type   = "t4g.small"
  count           = instance_count = 5
  azs             = var.azs
  fdb_version     = var.fdb_version
  cluster_id      = var.cluster_id
  fdb_cluster_file = ""
}

locals {
  fdb_description  = var.cluster_id
  fdb_id           = "abcd1234"
  fdb_cluster_file = format(
    "%s:%s@%s",
    local.fdb_description,
    local.fdb_id,
    join(",", [for ip in module.coordinators.private_ips : "${ip}:4500"])
  )
}

module "commit_proxies" {
  source          = "./Commit_proxy"
  ami_id          = data.aws_ami.ubuntu.id
  subnet_ids      = module.network.private_subnet_ids
  sg_id           = module.network.fdb_sg_id
  instance_type   = "c7g.large"
  count           = instance_count = 3
  azs             = var.azs
  fdb_version     = var.fdb_version
  cluster_id      = var.cluster_id
  fdb_cluster_file = local.fdb_cluster_file
}

module "grv_proxy" {
  source          = "./GRV_proxy"
  ami_id          = data.aws_ami.ubuntu.id
  subnet_ids      = module.network.private_subnet_ids
  sg_id           = module.network.fdb_sg_id
  instance_type   = "c7g.large"
  count           = instance_count = 1
  azs             = var.azs
  fdb_version     = var.fdb_version
  cluster_id      = var.cluster_id
  fdb_cluster_file = local.fdb_cluster_file
}

module "resolvers" {
  source          = "./Resolvers"
  ami_id          = data.aws_ami.ubuntu.id
  subnet_ids      = module.network.private_subnet_ids
  sg_id           = module.network.fdb_sg_id
  instance_type   = "c7g.large"
  count           = instance_count = 1
  azs             = var.azs
  fdb_version     = var.fdb_version
  cluster_id      = var.cluster_id
  fdb_cluster_file = local.fdb_cluster_file
}

module "tlogs" {
  source          = "./Tlogs"
  ami_id          = data.aws_ami.ubuntu.id
  subnet_ids      = module.network.private_subnet_ids
  sg_id           = module.network.fdb_sg_id
  instance_type   = "m7i.large"
  count           = instance_count = 4
  azs             = var.azs
  fdb_version     = var.fdb_version
  cluster_id      = var.cluster_id
  fdb_cluster_file = local.fdb_cluster_file
}

module "storage" {
  source          = "./Storage"
  ami_id          = data.aws_ami.ubuntu.id
  subnet_ids      = module.network.private_subnet_ids
  sg_id           = module.network.fdb_sg_id
  instance_type   = "m7i.large"
  count           = instance_count = 3
  azs             = var.azs
  fdb_version     = var.fdb_version
  cluster_id      = var.cluster_id
  fdb_cluster_file = local.fdb_cluster_file
}

module "backup_obs" {
  source          = "./Bcp_obs"
  ami_id          = data.aws_ami.ubuntu.id
  subnet_ids      = module.network.private_subnet_ids
  sg_id           = module.network.fdb_sg_id
  instance_type   = "m7i.large"
  count           = instance_count = 1
  azs             = var.azs
  fdb_version     = var.fdb_version
  cluster_id      = var.cluster_id
  fdb_cluster_file = local.fdb_cluster_file
  datadog_api_key = var.datadog_api_key
}

output "cluster_file_string" {
  value = local.fdb_cluster_file
}

output "coordinator_ips" {
  value = module.coordinators.private_ips
}
