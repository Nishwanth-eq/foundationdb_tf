# FoundationDB Terraform

A comprehensive Terraform Infrastructure-as-Code (IaC) solution for deploying a highly available FoundationDB three-data-hall cluster on AWS.

## Overview

This repository contains modular Terraform configurations to provision and manage a production-grade FoundationDB cluster across three availability zones with the following components:

### Architecture Components

- **Coordinators** (5 instances): Cluster metadata management across all AZs
- **Commit_proxy** (3 instances): Transaction commit proxies for load distribution
- **GRV_proxy** (1 instance): Get Read Version proxy for snapshot isolation
- **Resolvers** (1 instance): Transaction conflict resolution
- **Tlogs** (4 instances): Transaction logs with io2 Block Express volumes for high performance
- **Storage** (3 instances): Data storage nodes with gp3 volumes
- **Bcp_obs** (1 instance): Backup and observability node with Datadog integration
- **Network**: VPC infrastructure with private subnets across 3 AZs

## Directory Structure

```
.
├── README.md                 # This file
├── main.tf                   # Root module configuration
├── variables.tf              # Root module variables
├── data-ami.tf              # AMI data source
├── Coordinators/            # Coordinator module
│   ├── main.tf
│   ├── variables.tf
│   └── userdata.tpl
├── Commit_proxy/            # Commit proxy module
│   ├── main.tf
│   ├── variables.tf
│   └── userdata.tpl
├── GRV_proxy/               # GRV proxy module
│   ├── main.tf
│   ├── variables.tf
│   └── userdata.tpl
├── Resolvers/               # Resolver module
│   ├── main.tf
│   ├── variables.tf
│   └── userdata.tpl
├── Tlogs/                   # Transaction logs module
│   ├── main.tf
│   ├── variables.tf
│   └── userdata.tpl
├── Storage/                 # Storage module
│   ├── main.tf
│   ├── variables.tf
│   └── userdata.tpl
├── Bcp_obs/                 # Backup & observability module
│   ├── main.tf
│   ├── variables.tf
│   └── userdata.tpl
└── network/                 # Network module
    └── main.tf
```

## Features

- **Modular Design**: Each component is independently deployable
- **High Availability**: Multi-AZ deployment with 3 availability zones
- **Auto-Scaling**: Configured for proper resource allocation
- **Storage Optimization**: 
  - io2 Block Express volumes for Tlogs with 16,000 IOPS and 1,000 MB/s throughput
  - gp3 volumes for Storage with 3,000 IOPS and 125 MB/s throughput
- **Monitoring**: Integrated Datadog support for observability
- **Security**: VPC isolation with security groups and IAM roles

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions
- Datadog API key (optional, for monitoring)

## Variables

Key variables for deployment:

```hcl
aws_region       = "us-east-1"          # AWS region
vpc_id          = "vpc-xxxxx"           # VPC ID
private_subnets = ["subnet-1", ...]    # Private subnets (min 3)
azs              = ["us-east-1a", ...]  # Availability zones (min 3)
datadog_api_key = ""                    # Datadog API key (optional)
```

## Deployment

### Initialize Terraform

```bash
terraform init
```

### Review Plan

```bash
terraform plan -out=tfplan
```

### Apply Configuration

```bash
terraform apply tfplan
```

### Verify Cluster

```bash
# SSH into any instance and use fdbcli
fdbcli
> status
```

## Module Details

### Tlogs Module
- **Instance Type**: m7i.large
- **Count**: 4 instances
- **Storage**: 500 GB io2 Block Express volumes (16,000 IOPS, 1,000 MB/s)
- **Purpose**: High-performance transaction logging

### Storage Module
- **Instance Type**: m7i.large
- **Count**: 3 instances (one per AZ)
- **Storage**: 2000 GB gp3 volumes (3,000 IOPS, 125 MB/s)
- **Purpose**: Data persistence

### Bcp_obs Module
- **Instance Type**: m7i.large
- **Count**: 1 instance
- **Purpose**: Backup operations and system observability
- **Features**: Datadog agent integration for monitoring

## Monitoring

The deployment includes Datadog integration for:
- System metrics (CPU, Memory, Disk)
- FoundationDB performance metrics
- Transaction latency and throughput

To enable Datadog monitoring, provide `datadog_api_key` variable.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Security Considerations

- All instances are in private subnets
- Security groups restrict traffic to port 4500 (FoundationDB)
- IAM roles follow principle of least privilege
- Sensitive variables (like datadog_api_key) should be managed via Terraform Cloud or AWS Secrets Manager

## Troubleshooting

### Cluster Not Forming
Check instance connectivity and FoundationDB logs:
```bash
sudo journalctl -u foundationdb -n 50
```

### Volume Mount Issues
Verify volume attachment and mount points:
```bash
lsblk
mount | grep storage
```

## Contributing

For improvements or bug fixes, please create a pull request with detailed description.

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
1. Check FoundationDB documentation: https://apple.github.io/foundationdb/
2. Review Terraform state and logs
3. Consult AWS documentation for specific AWS services
