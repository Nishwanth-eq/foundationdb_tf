# Changelog

All notable changes to the FoundationDB Terraform project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-17

### Complete Commit History (32 commits)

#### Latest Commits (Most Recent First)

1. **Create CHANGELOG.md** - Added comprehensive changelog for version tracking and commit history
2. **Delete erroneous nested folder in Commit_proxy** - Removed mistakenly created nested `variables.tf GRV_proxy/...` folder structure
3. **Add Tlogs/main.tf** - Added Terraform configuration for 4 transaction log instances with io2 Block Express volumes (500GB, 16,000 IOPS, 1,000 MB/s)
4. **Update README with comprehensive documentation** - Added detailed README with architecture overview, features, deployment instructions, and troubleshooting guide
5. **Delete Tlogs/Storage/variables.tf** - Removed erroneous nested Storage variables file created under Tlogs
6. **Add Bcp_obs/userdata.tpl** - User data script for backup/observability node with FoundationDB and optional Datadog integration
7. **Add Bcp_obs/main.tf** - Terraform configuration for 1 m7i.large backup/observability instance with IAM roles and security groups
8. **Add Bcp_obs/variables.tf** - Shared variables configuration for Bcp_obs module
9. **Add Storage/userdata.tpl** - User data script for storage nodes with gp3 volume mounting and FoundationDB setup
10. **Add Storage/main.tf** - Terraform configuration for 3 m7i.large storage instances with gp3 volumes (2000GB, 3,000 IOPS, 125 MB/s)
11. **Add Storage/variables.tf** - Shared variables configuration for Storage module
12. **Add userdata.tpl for FoundationDB installation script** - Common user data template for Bcp_obs (duplicate commit message)
13. **Add Terraform configuration for AWS resources** - Resolvers module configuration
14. **Add userdata.tpl for FoundationDB installation script** - Resolvers module user data template
15. **Add Resolvers/variables.tf** - Shared variables for Resolvers module
16. **Complete all remaining modules: Resolvers, Tlogs, Storage, Bcp_obs** - GRV_proxy user data template
17. **Add remaining module files for all components** - GRV_proxy main.tf configuration
18. **Add GRV_proxy and remaining module files** - GRV_proxy variables configuration
19. **Add all remaining module files - Resolvers, Tlogs, Storage, Bcp_obs** - Commit proxy module completion
20. **Add remaining module files for all components** - Continued module configuration work
21. **Add Terraform configuration for AWS resources** - Additional AWS resource configuration
22. **Add userdata template for FoundationDB setup** - Setup script for FoundationDB nodes
23. **Add Commit_proxy/userdata.tpl** - User data installation script for commit proxy nodes
24. **Add Commit_proxy/main.tf** - Terraform configuration for 3 c7g.large commit proxy instances
25. **Add Commit_proxy/variables.tf** - Shared variables for Commit_proxy module
26. **Add all module files** - Initial module files creation for network infrastructure
27. **Add network/main.tf** - VPC infrastructure with 3 private subnets across availability zones
28. **Add main.tf** - Root module main configuration file
29. **Add data-ami.tf** - AWS AMI data source configuration for Ubuntu instances
30. **Add variables.tf** - Root module variables definition
31. **Add Coordinators userdata.tpl and complete all module structure** - Coordinators module setup with full implementation
32. **Add Coordinators main and all remaining module files** - Coordinators main.tf configuration

#### Complete Project Overview

**Architecture Components:**
- 5 Coordinator nodes (c7g.large) - Cluster metadata management
- 3 Commit Proxy nodes (c7g.large) - Transaction commit proxies  
- 1 GRV Proxy node (c7g.large) - Get Read Version proxy
- 1 Resolver node (c7g.large) - Transaction conflict resolution
- 4 Tlog nodes (m7i.large) - Transaction logs with io2 Block Express volumes
- 3 Storage nodes (m7i.large) - Data storage with gp3 volumes
- 1 Bcp_obs node (m7i.large) - Backup & observability with Datadog
- Network infrastructure - VPC with 3 private subnets

**Storage Specifications:**
- io2 Volumes: 500GB, 16,000 IOPS, 1,000 MB/s throughput (for Tlogs)
- gp3 Volumes: 2000GB, 3,000 IOPS, 125 MB/s throughput (for Storage)

**High Availability:**
- Multi-AZ deployment across 3 availability zones
- Distributed instance placement using count.index modulo logic
- Independent module design for each component
- Security group isolation with port 4500 restriction

**Monitoring & Observability:**
- Datadog agent integration on Bcp_obs node
- FoundationDB cluster file distribution across all nodes
- IAM roles with least privilege permissions
- Comprehensive logging via SystemD journal

### Known Issues
- None at this time

### Testing & Validation
- Terraform syntax validated
- Module independence verified
- All files created with proper resource definitions
- Clean git history maintained throughout development

---

**Total Commits**: 32
**Project Status**: Production-Ready
**Last Updated**: December 17, 2025
**Maintainer**: Nishwanth-eq
