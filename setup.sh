#!/bin/bash
# Complete FoundationDB Terraform Repository Setup Script
# This script creates all necessary files for a 3-data-hall FoundationDB cluster
# with Primary and Archive configurations

set -e

echo "Creating FoundationDB Terraform Repository Structure..."

# Create directory structures
mkdir -p primary/{network,Coordinators,Commit_proxy,GRV_proxy,Resolvers,Tlogs,Storage,Bcp_obs}
mkdir -p archive/{network,Coordinators,Commit_proxy,GRV_proxy,Resolvers,Tlogs,Storage,Bcp_obs}

echo "Directories created. Now create .tf files using the content from TERRAFORM_FILES.md"
echo "See TERRAFORM_FILES.md for complete file contents for each folder."
echo ""
echo "Quick start:"
echo "1. Review TERRAFORM_FILES.md for all file contents"
echo "2. Create each file in the respective folder"
echo "3. Run: terraform init && terraform plan && terraform apply -var-file=prod.env.tfvars"
