# Changelog

All notable changes to the FoundationDB Terraform project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial CHANGELOG.md for version tracking
- Comprehensive project documentation with README.md

## [1.0.0] - 2025-12-17

### Added
- Complete FoundationDB three-data-hall cluster Terraform configuration
- All 8 FoundationDB component modules:
  - **Coordinators**: 5 c7g.large instances for cluster metadata management
  - **Commit_proxy**: 3 c7g.large instances for transaction commit proxies
  - **GRV_proxy**: 1 c7g.large instance for Get Read Version proxy
  - **Resolvers**: 1 c7g.large instance for transaction conflict resolution
  - **Tlogs**: 4 m7i.large instances with io2 Block Express volumes (500GB, 16,000 IOPS, 1,000 MB/s)
  - **Storage**: 3 m7i.large instances with gp3 volumes (2000GB, 3,000 IOPS, 125 MB/s)
  - **Bcp_obs**: 1 m7i.large instance for backup and observability with Datadog integration
  - **Network**: VPC infrastructure with 3 private subnets across availability zones

### Features
- Multi-AZ deployment across 3 availability zones for high availability
- High-performance io2 Block Express volumes for transaction logs
- gp3 volumes for data storage with 3,000 IOPS
- IAM roles and instance profiles with least privilege permissions
- Security groups restricting communication to port 4500
- FoundationDB cluster file management and distribution
- Datadog monitoring integration for observability
- Terraform modules with consistent variable interfaces
- Auto-scaling configuration for resource distribution

### Documentation
- Comprehensive README.md with:
  - Architecture overview
  - Directory structure
  - Feature descriptions
  - Prerequisites and setup instructions
  - Deployment workflow
  - Module details with specifications
  - Troubleshooting guide
  - Security considerations

### Infrastructure Specifications
- **Coordinators**: 5 instances, c7g.large, all AZs
- **Commit Proxies**: 3 instances, c7g.large, 1 per AZ
- **GRV Proxy**: 1 instance, c7g.large
- **Resolvers**: 1 instance, c7g.large
- **Transaction Logs**: 4 instances, m7i.large, 2-1-1 distribution, io2 storage
- **Storage**: 3 instances, m7i.large, 1 per AZ, gp3 storage
- **Backup/Observer**: 1 instance, m7i.large, Datadog enabled

### Initial Commits
1. Root configuration files (main.tf, variables.tf, data-ami.tf)
2. Network module setup
3. Coordinators module configuration
4. Commit_proxy module configuration
5. GRV_proxy module configuration
6. Resolvers module configuration
7. Tlogs module with io2 volume configuration
8. Storage module with gp3 volume configuration
9. Bcp_obs module with Datadog integration
10. README.md documentation
11. Project cleanup (removed erroneous nested folders)
12. Tlogs/main.tf addition
13. Erroneous Commit_proxy nested folder deletion

### Known Issues
- None at this time

### Future Enhancements
- Terraform Cloud integration for state management
- Automated testing with terraform validate and tflint
- Backup and disaster recovery procedures
- Cost optimization analysis
- Enhanced monitoring dashboards
- Auto-scaling policies based on metrics
- Replication setup for cross-region failover
- SSL/TLS certificate management

### Migration Guide
For upgrading to this version:
1. Review the README.md for prerequisites
2. Update terraform version to >= 1.0
3. Configure AWS credentials appropriately
4. Initialize Terraform: `terraform init`
5. Review changes: `terraform plan -out=tfplan`
6. Apply configuration: `terraform apply tfplan`
7. Verify cluster: `fdbcli > status`

## Development Notes

### Version Control
- All changes tracked with clear commit messages
- Each module is independently deployable
- Clean git history without erroneous nested folders

### Testing
- Terraform syntax validation: `terraform validate`
- Linting: Use tflint for best practices
- Manual testing on AWS resources
- Verification using fdbcli

### Deployment Checklist
- [ ] Review all Terraform files
- [ ] Run terraform validate
- [ ] Run terraform plan
- [ ] Review resource creation plan
- [ ] Apply terraform configuration
- [ ] Wait for EC2 instances to boot
- [ ] Verify FoundationDB cluster formation
- [ ] Check monitoring in Datadog
- [ ] Document any customizations

### Support and Issues
For issues or questions:
1. Review the README.md and troubleshooting section
2. Check FoundationDB logs: `sudo journalctl -u foundationdb -n 50`
3. Verify network connectivity: `nc -zv coordinator-ip 4500`
4. Review Terraform state: `terraform state show`
5. Consult FoundationDB documentation: https://apple.github.io/foundationdb/

---

**Last Updated**: December 17, 2025
**Maintainer**: Nishwanth-eq
**Repository**: foundationdb_tf
