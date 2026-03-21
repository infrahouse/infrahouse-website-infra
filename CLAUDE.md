# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## First Steps

**Your first tool call in this repository MUST be reading
.claude/CODING_STANDARD.md. Do not read any other files, search, or take
any actions until you have read it.**
This contains InfraHouse's comprehensive coding standards for Terraform,
Python, and general formatting rules.

## Project Overview

This is the **infrahouse-website-infra** repository — a Terraform root
module that deploys the infrahouse.com website infrastructure on AWS.
It is a **production** environment deploying to AWS account
`493370826424` in `us-west-1`.

## Commands

```bash
make help              # List all targets
make bootstrap         # Install dev dependencies (assumes virtualenv),
                       # also installs git hooks
make bootstrap-ci      # Install CI-only dependencies
make lint              # Check code style (yamllint on workflows
                       # + terraform fmt -check)
make format            # Auto-format Terraform files
make init              # terraform init
make plan              # terraform init + plan
                       # (outputs to tf.plan, plan.stdout, plan.stderr)
make apply             # terraform apply from tf.plan
                       # (requires a prior `make plan`)
```

The pre-commit hook runs `make lint` and is installed by `make bootstrap`
(via the `install-hooks` target).

## Architecture

### Root Module

The root module provisions two main components:

1. **Website (www.tf)** — Uses the `infrahouse/website-pod/aws`
   registry module to deploy an ALB-backed ASG running EC2 instances
   with Puppet-managed configuration. The instances use Ubuntu Noble
   (24.04) Pro AMIs and are bootstrapped via
   `infrahouse/cloud-init/aws` for userdata generation.

2. **CDN (cdn.tf)** — Uses a local module (`./modules/cdn`)
   instantiated twice: `cdn` and `cdn-staging`. Each creates a
   CloudFront distribution fronting `infrahouse.com` with ACM
   certificates (in `us-east-1` for CloudFront), Route53 DNS records,
   and geo-restrictions.

### Provider Layout (providers.tf)

Three AWS provider configurations, all assuming the `tf_admin_arn` role:
- Default (`aws`) — `us-west-1`
- `aws-uw1` — `us-west-1` (explicit alias, used by most modules)
- `aws-ue1` — `us-east-1` (required for CloudFront ACM certificates)

### State Management

Terraform state is stored in S3 bucket `infrahouse-website-infra`
(us-west-1) with DynamoDB locking. A separate IAM role
(`ih-tf-infrahouse-website-infra-state-manager` in account
`289256138624`) manages state access.

### CI/CD (GitHub Actions)

- **CI (terraform-CI.yml)**: On pull requests — lint, validate, plan.
  Uploads the plan artifact to S3 via `ih-plan`.
- **CD (terraform-CD.yml)**: On PR merge — downloads the approved plan
  from S3, applies it, then removes the plan artifact.

Both workflows use OIDC (`id-token: write`) for AWS authentication and
run with `concurrency: terraform` (no cancellation) to prevent
concurrent Terraform operations.

### Key Details

- Terraform version pinned in `.terraform-version` (currently 1.14.5)
- AWS provider: `hashicorp/aws ~> 6.0`
- InfraHouse modules use `registry.infrahouse.com`
  (not the public Terraform registry)
- Renovate manages dependency updates (`renovate.json`), with GitHub
  Actions workflow versions excluded from auto-updates
- Variables are defined in `terraform.tfvars` — `environment`,
  `repo_name`, `tf_admin_arn`
- Data sources (`data_sources.tf`) look up the management VPC, subnets,
  IGW, AMIs, Route53 zone, and SSH key pair
