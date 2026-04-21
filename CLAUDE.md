# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Production-style 3-tier web application on AWS, provisioned entirely with Terraform. The three tiers are:

1. **Load Balancer tier** — AWS ALB (`alb.tf`) terminates HTTP/HTTPS and distributes traffic
2. **Application tier** — EC2 instances running PHP (`app/index.php`), bootstrapped via `user_data.sh`
3. **Data tier** — RDS database (`rds.tf`)

Networking (`vpc.tf`), security groups (`security_groups.tf`), and outputs (`outputs.tf`) connect these tiers. CI/CD is handled by GitHub Actions (`.github/workflows/terraform.yml`).

## Terraform Commands

All Terraform commands run from the `terraform/` directory.

```bash
cd terraform

# One-time setup
terraform init

# Preview changes
terraform plan -var-file=terraform.tfvars

# Apply infrastructure
terraform apply -var-file=terraform.tfvars

# Destroy all resources
terraform destroy -var-file=terraform.tfvars

# Format and validate
terraform fmt -recursive
terraform validate
```

## Configuration

Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` (git-ignored) and fill in values before running any Terraform commands. The `.gitignore` also excludes:

- `*.tfstate` / `.terraform/` / `.terraform.lock.hcl` — state and provider cache
- `terraform.tfvars` — secrets/config
- `*.pem` / `three-tier-key` / `*.pub` — SSH key material

## CI/CD

GitHub Actions (`.github/workflows/terraform.yml`) runs Terraform automatically. AWS credentials must be set as repository secrets for the workflow to authenticate.

## Architecture Notes

- EC2 instances receive their software stack (PHP, web server) via the cloud-init script in `terraform/user_data.sh` — changes to the app bootstrap go there, not in AMI selection.
- Security groups in `security_groups.tf` encode the tier boundaries: only the ALB security group should allow inbound from the internet; EC2 only from ALB; RDS only from EC2.
- `outputs.tf` exposes the ALB DNS name and other runtime values after `terraform apply`.
