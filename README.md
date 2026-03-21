# infrahouse-website-infra

Terraform root module that deploys the [infrahouse.com](https://infrahouse.com)
website infrastructure on AWS (account `493370826424`, `us-west-1`).

## Components

### Website

An ALB-backed Auto Scaling Group running EC2 instances on Ubuntu Noble (24.04) Pro AMIs.
Instances are bootstrapped via cloud-init and configured with Puppet.
Serves both `infrahouse.com` and `www.infrahouse.com`.

### CDN

Two CloudFront distributions (`cdn.infrahouse.com` and `cdn-staging.infrahouse.com`)
fronting the website origin with:
- TLSv1.2-only origin connections and viewer certificates
- Brotli and gzip compression
- Geo-restrictions (RU, CN, IR blocked)
- Access logging to S3 with 365-day retention
- ACM certificates (provisioned in `us-east-1`)

## CI/CD

- **CI** (`terraform-CI.yml`): On pull requests — lint, validate, plan.
  Uploads the plan artifact to S3 via `ih-plan`.
- **CD** (`terraform-CD.yml`): On PR merge — downloads the approved plan,
  applies it, then removes the plan artifact.

Both workflows use OIDC for AWS authentication and run with
`concurrency: terraform` to prevent concurrent Terraform operations.

## Usage

```bash
make bootstrap    # Install dependencies and git hooks
make lint         # Check code style
make plan         # terraform init + plan
make apply        # terraform apply from plan
make clean        # Remove build artifacts
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cdn"></a> [cdn](#module\_cdn) | ./modules/cdn | n/a |
| <a name="module_cdn-staging"></a> [cdn-staging](#module\_cdn-staging) | ./modules/cdn | n/a |
| <a name="module_cdn_access_logs"></a> [cdn\_access\_logs](#module\_cdn\_access\_logs) | registry.infrahouse.com/infrahouse/s3-bucket/aws | 0.3.1 |
| <a name="module_webserver_userdata"></a> [webserver\_userdata](#module\_webserver\_userdata) | registry.infrahouse.com/infrahouse/cloud-init/aws | 2.2.2 |
| <a name="module_website"></a> [website](#module\_website) | registry.infrahouse.com/infrahouse/website-pod/aws | 5.8.2 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_lifecycle_configuration.cdn_access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_ami.ubuntu_pro](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.uw1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.cdn_logs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.webserver_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_internet_gateway.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway) | data source |
| [aws_key_pair.aleks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/key_pair) | data source |
| [aws_route53_zone.infrahouse_com](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.management_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.management_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | GitHub repository name in org/repo format (used for created\_by tag). | `string` | n/a | yes |
| <a name="input_tf_admin_arn"></a> [tf\_admin\_arn](#input\_tf\_admin\_arn) | ARN of the IAM role to assume for Terraform administrative operations. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
