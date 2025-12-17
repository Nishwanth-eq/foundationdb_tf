# Complete FoundationDB Terraform Cluster Setup Guide

This repository contains a complete, production-ready Terraform configuration for deploying a FoundationDB 3-data-hall cluster on AWS with primary and archive configurations.

## Repository Structure

```
foundationdb_tf/
├── primary/
│   ├── main.tf
│   ├── variables.tf
│   ├── network/
│   │   └── main.tf
│   ├── Coordinators/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── userdata.tpl
│   ├── Commit_proxy/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── userdata.tpl
│   ├── GRV_proxy/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── userdata.tpl
│   ├── Resolvers/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── userdata.tpl
│   ├── Tlogs/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── userdata.tpl
│   ├── Storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── userdata.tpl
│   └── Bcp_obs/
│       ├── main.tf
│       ├── variables.tf
│       └── userdata.tpl
├── archive/
│   └── [identical structure to primary]
├── prod.env.tfvars
├── dev.env.tfvars
├── setup.sh
└── README.md
```

## Components Overview

### Network Module
- VPC with 3 private subnets (one per AZ)
- Security groups for FoundationDB communication
- NAT gateway for outbound connectivity

### Cluster Components
- **Coordinators** (5x t4g.small): 2/2/1 AZ spread
- **Commit Proxies** (3x c7g.large): 1 per AZ
- **GRV Proxy** (1x c7g.large): Any AZ
- **Resolvers** (1x c7g.large): Any AZ  
- **TLogs** (4x m7i.large): 2/1/1 AZ spread with io2 Block Express
- **Storage** (3x m7i.large): 1 per AZ with gp3 EBS
- **Backup/Observability** (1x m7i.large): Datadog integration

## Deployment Instructions

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with EC2, VPC, EBS permissions

### Setup

1. Clone or navigate to this repository
2. Copy `prod.env.tfvars` or `dev.env.tfvars` as needed
3. Run setup script to create directory structure:
```bash
bash setup.sh
```

### Deploy Primary Cluster (Production)

```bash
cd primary
terraform init
terraform plan -var-file=../prod.env.tfvars
terraform apply -var-file=../prod.env.tfvars
```

### Deploy Archive Cluster (Backup)

```bash
cd archive
terraform init
terraform plan -var-file=../prod.env.tfvars
terraform apply -var-file=../prod.env.tfvars
```

### Dev Environment

```bash
cd primary
terraform apply -var-file=../dev.env.tfvars
```

## Environment Variables

### prod.env.tfvars
```hcl
aws_region = "us-east-1"
cluster_id = "fdb-prod-cluster"
fdb_version = "7.4.5"
vpc_cidr = "10.0.0.0/16"
azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
datadog_api_key = "your-datadog-api-key"
```

### dev.env.tfvars
```hcl
aws_region = "us-east-1"
cluster_id = "fdb-dev-cluster"
fdb_version = "7.4.5"
vpc_cidr = "10.1.0.0/16"
azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
datadog_api_key = ""
```

## Post-Deployment Configuration

After deployment, configure the cluster:

```bash
fdbcli --exec "configure three_data_hall"
fdbcli --exec "coordinator set <coordinator_ips>"
```

## Key Features

- **Modular Design**: Each component in separate Terraform module
- **Three-Data-Hall Redundancy**: Production-grade high availability
- **Multi-Environment**: Separate prod and dev configurations
- **Primary/Archive Support**: Dual cluster setup for backups
- **Cloud-Init**: Automated FoundationDB installation and configuration
- **Datadog Integration**: Built-in observability
- **NVMe Optimized**: Uses io2 Block Express for TLogs

## Troubleshooting

### Module not found
Ensure all files are created in their respective folders as per directory structure.

### Terraform validation errors
Check that all .tf files are properly formatted and variables are defined.

### FoundationDB cluster not forming
Verify coordinator IPs and cluster file configuration in foundationdb.conf

## Support & Documentation

For more information:
- [FoundationDB Official Docs](https://apple.github.io/foundationdb/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

This configuration is provided as-is for FoundationDB deployment on AWS.
