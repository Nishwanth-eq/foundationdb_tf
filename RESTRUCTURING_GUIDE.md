# FoundationDB Terraform - Restructuring Guide

## Objective
Restructure the repository to support:
- **2 Cluster Types**: Primary (active) and Archive (backup/standby)
- **2 Environments**: Production (prod) and Development (dev)
- Each cluster type has identical component modules
- Environment-specific variables and configurations

## Target Directory Structure

```
foundationdb_tf/
├── prod/
│   ├── primary/
│   │   ├── Coordinators/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── userdata.tpl
│   │   ├── Commit_proxy/
│   │   ├── GRV_proxy/
│   │   ├── Resolvers/
│   │   ├── Tlogs/
│   │   ├── Storage/
│   │   ├── Bcp_obs/
│   │   ├── network/
│   │   ├── main.tf (cluster-level main)
│   │   ├── variables.tf
│   │   └── terraform.tfvars (prod/primary-specific)
│   ├── archive/
│   │   ├── Coordinators/
│   │   ├── Commit_proxy/
│   │   ├── ... (same structure as primary)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars (prod/archive-specific)
│   ├── prod.tfvars (prod environment-level variables)
│   └── main.tf (prod-level orchestration)
├── dev/
│   ├── primary/
│   │   ├── ... (same structure as prod/primary)
│   │   └── terraform.tfvars (dev/primary-specific)
│   ├── archive/
│   │   ├── ... (same structure as prod/archive)
│   │   └── terraform.tfvars (dev/archive-specific)
│   ├── dev.tfvars (dev environment-level variables)
│   └── main.tf (dev-level orchestration)
├── shared/
│   ├── versions.tf (Terraform version constraints)
│   ├── provider.tf (AWS provider configuration)
│   └── backend.tf (State management configuration)
├── CHANGELOG.md
├── README.md
└── RESTRUCTURING_GUIDE.md (this file)
```

## Key Differences Between Environments

### Prod Environment
- Instance types: c7g.large, m7i.large (production-grade)
- Availability Zones: 3 AZs (us-east-1a, us-east-1b, us-east-1c)
- Storage volumes: io2 (16,000 IOPS), gp3 (3,000 IOPS)
- Backup retention: Extended (30+ days)
- Monitoring: Full Datadog integration

### Dev Environment
- Instance types: t3.medium or t4g.medium (cost-optimized)
- Availability Zones: 1-2 AZs (same region, single AZ acceptable)
- Storage volumes: gp3 (1,000 IOPS) or gp2
- Backup retention: Limited (7 days)
- Monitoring: Basic CloudWatch

## Cluster Type Differences

### Primary Cluster
- Active cluster handling production traffic
- Full replication enabled
- Regular backup schedule
- Monitoring and alerting enabled

### Archive Cluster
- Standby/backup cluster
- Synchronous or asynchronous replication from primary
- Can be used for analytics/reporting
- Reduced monitoring (non-critical)

## Restructuring Steps

### Step 1: Create Directory Structure
```bash
# Create all required directories
mkdir -p prod/primary prod/archive dev/primary dev/archive shared
```

### Step 2: Copy Existing Modules to prod/primary
- Copy all component modules (Coordinators, Commit_proxy, etc.) from root to prod/primary/
- Copy network module to prod/primary/
- Copy main.tf, variables.tf to prod/primary/

### Step 3: Duplicate prod/primary to prod/archive
- Copy entire prod/primary/ to prod/archive/
- Update terraform.tfvars in prod/archive/ with archive-specific settings
  - Different cluster file name
  - Different instance naming conventions

### Step 4: Duplicate prod/ to dev/
- Copy entire prod/ structure to dev/
- Update all tfvars files with dev-specific values:
  - Smaller instance types
  - Reduced storage capacity
  - Single AZ deployment for cost savings

### Step 5: Create Shared Configuration
Create shared/backend.tf:
```hcl
terraform {
  backend "s3" {
    bucket = "foundationdb-tf-state"
    key    = "foundationdb/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

Create shared/versions.tf:
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

Create shared/provider.tf:
```hcl
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ClusterType = var.cluster_type
      Project     = "FoundationDB"
      ManagedBy   = "Terraform"
    }
  }
}
```

### Step 6: Create Environment tfvars Files

prod/prod.tfvars:
```hcl
environment = "prod"
aws_region = "us-east-1"
instance_count = {
  coordinators = 5
  commit_proxy = 3
  grv_proxy    = 1
  resolvers    = 1
  tlogs        = 4
  storage      = 3
  bcp_obs      = 1
}
instance_types = {
  compute = "c7g.large"
  storage = "m7i.large"
}
```

dev/dev.tfvars:
```hcl
environment = "dev"
aws_region = "us-east-1"
instance_count = {
  coordinators = 3
  commit_proxy = 2
  grv_proxy    = 1
  resolvers    = 1
  tlogs        = 2
  storage      = 2
  bcp_obs      = 1
}
instance_types = {
  compute = "t4g.medium"
  storage = "t4g.large"
}
```

### Step 7: Create Cluster-Specific tfvars

prod/primary/terraform.tfvars:
```hcl
cluster_type = "primary"
cluster_name = "prod-primary"
fdb_cluster_id = "prod-primary:q1q2s1"
```

prod/archive/terraform.tfvars:
```hcl
cluster_type = "archive"
cluster_name = "prod-archive"
fdb_cluster_id = "prod-archive:q1q2s1"
replication_type = "async"
```

### Step 8: Update CHANGELOG and README
- Document the new structure
- Add deployment instructions for each environment/cluster combination
- Update README with new directory explanations

## Deployment Commands

### Deploy Production Primary
```bash
cd prod/primary
terraform init
terraform plan -var-file=../prod.tfvars -var-file=terraform.tfvars
terraform apply
```

### Deploy Production Archive
```bash
cd prod/archive
terraform init
terraform plan -var-file=../prod.tfvars -var-file=terraform.tfvars
terraform apply
```

### Deploy Development Primary
```bash
cd dev/primary
terraform init
terraform plan -var-file=../dev.tfvars -var-file=terraform.tfvars
terraform apply
```

## Validation Checklist

- [ ] All directories created (prod/primary, prod/archive, dev/primary, dev/archive)
- [ ] All component modules duplicated to each cluster directory
- [ ] Environment-level tfvars files created and configured
- [ ] Cluster-level tfvars files created and configured
- [ ] Shared configuration (versions.tf, provider.tf, backend.tf) created
- [ ] All modules reference correct variables from tfvars
- [ ] Terraform init works in each cluster directory
- [ ] Terraform validate passes for all configurations
- [ ] Documentation updated (CHANGELOG, README)
- [ ] Git history maintained with appropriate commit messages

## Git Workflow for Restructuring

```bash
# 1. Create branch for restructuring
git checkout -b feature/multi-cluster-multi-env

# 2. Make all structural changes
# (Create directories, copy files, update configurations)

# 3. Validate all terraform files
for dir in prod/primary prod/archive dev/primary dev/archive; do
  (cd $dir && terraform validate) || exit 1
done

# 4. Commit with clear message
git commit -m "Restructure for multi-cluster multi-environment support

- Created prod and dev environment directories
- Each environment has primary and archive clusters
- Duplicated all component modules to each cluster
- Created environment-specific tfvars
- Created shared configuration files
- Maintains identical component count per cluster type"

# 5. Merge to main after review
git checkout main
git pull origin main
git merge feature/multi-cluster-multi-env
git push origin main
```

## Notes

- All cluster types (primary and archive) have identical component counts and specifications
- Environment differences (prod vs dev) are managed via tfvars files
- Cluster-specific differences are also managed via tfvars files
- This structure allows independent scaling and management of each cluster type
- State files should be stored separately for each cluster to prevent conflicts

---

**Document Version**: 1.0
**Last Updated**: December 17, 2025
**Status**: Ready for implementation
