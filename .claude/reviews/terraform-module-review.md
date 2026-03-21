# Terraform Module Review: infrahouse-website-infra (Follow-Up #2)

**Last Updated: 2026-03-21**

---

## Progress Summary

**19 of 21 original issues fixed, 0 still present from previous review, 1 new issue found.**

| Category | Fixed (Total) | Still Present | New |
|----------|---------------|---------------|-----|
| Critical | 2/2 | 0 | 0 |
| High | 5/5 | 0 | 0 |
| Medium | 10/10 | 0 | 0 |
| Low | 2/4 | 0 | 1 |

Since the last follow-up review, three previously-open issues have been resolved:
- **M2** (CDN module `required_version`): Updated to `~> 1.14`
- **M8** (CDN module resource naming): Renamed from `repo` to `this`
- **NEW-H1** (hardcoded bucket name/account ID): Extracted to local and `data.aws_caller_identity`

The codebase is now in excellent shape. All critical, high, and medium severity
issues are resolved. Only minor/cosmetic items remain.

---

## Executive Summary

This second follow-up review evaluates the changes made since the first follow-up.
The diff shows a comprehensive cleanup that resolves every remaining medium+ issue:

- **CDN module version alignment**: `modules/cdn/terraform.tf:2` now reads
  `required_version = "~> 1.14"`, matching the root module.
- **Resource naming**: All CDN module resources renamed from `repo` to `this`
  (`aws_cloudfront_distribution.this`, `aws_route53_record.this`,
  `aws_acm_certificate_validation.this`), following the coding standard for
  single resources of a type.
- **DRY bucket name**: `locals.tf:4` defines `cdn_logs_bucket_name`, used in
  both `cdn-logs.tf:4` (module call) and `cdn-logs.tf:18` (bucket policy ARN).
- **Account ID from data source**: `data_sources.tf:1` adds
  `data "aws_caller_identity" "current" {}`, and `cdn-logs.tf:22` uses
  `data.aws_caller_identity.current.account_id` instead of the hardcoded
  `493370826424`.
- **Module rename**: `cdn.tf:7` now uses `cdn_staging` (underscore) instead
  of `cdn-staging` (hyphen), fixing the snake_case naming violation.
- **Trailing newlines**: `cdn.tf` and `variables.tf` now end with proper
  newlines.

---

## Findings by Previous Issue

### Critical Issues

#### C1: CloudFront Origin Uses Deprecated TLS Protocols

FIXED (confirmed in previous review): `modules/cdn/main.tf:16` reads
`origin_ssl_protocols = ["TLSv1.2"]`.

#### C2: CDN Module Missing `minimum_protocol_version` on Viewer Certificate

FIXED (confirmed in previous review): `modules/cdn/main.tf:36` includes
`minimum_protocol_version = "TLSv1.2_2021"`.

---

### High Severity

#### H1: Root Variables Missing Type Constraints and Descriptions

FIXED (confirmed in previous review): `variables.tf:1-24` has `type = string`,
descriptions, and validation blocks for all three variables.

#### H2: CDN Module Variable Missing Type Constraint

FIXED (confirmed in previous review): `modules/cdn/variables.tf:1-4` has
`type = string` on `cdn_hostname`.

#### H3: InfraHouse Module Uses Public Registry Instead of Private Registry

FIXED (confirmed in previous review): Both modules in `www.tf` use
`registry.infrahouse.com`.

#### H4: CloudFront Distribution Missing Access Logging

FIXED (confirmed in previous review): `modules/cdn/main.tf:39-43` has a
`logging_config` block; `cdn-logs.tf` provisions the bucket with 365-day
lifecycle.

#### H5: Wildcard IAM Permission for EC2 Resources

FIXED (confirmed in previous review): `www.tf:37` uses
`actions = ["sts:GetCallerIdentity"]`.

---

### Medium Severity

#### M1: CDN Module Provider Version Constraint Too Loose

FIXED (confirmed in previous review): `modules/cdn/terraform.tf:5` reads
`version = "~> 6.0"`.

#### M2: CDN Module Terraform Version Constraint Inconsistent with Root

FIXED: `modules/cdn/terraform.tf:2` now reads `required_version = "~> 1.14"`,
matching the root module's `terraform.tf:2`.

#### M3: Missing `outputs.tf` Files

FIXED (confirmed in previous review): `modules/cdn/outputs.tf` exists with
`distribution_id` and `distribution_domain_name` outputs. Root module has no
`outputs.tf`, acceptable for a root deployment module.

#### M4: Stale AMI Data Source (Ubuntu 22.04)

FIXED (confirmed in previous review): `data "aws_ami" "ubuntu_22"` removed.

#### M5: `data.aws_vpc.management` and Subnet Data Sources Missing Provider

RESOLVED (confirmed in previous review): Duplicate provider aliases removed;
all data sources use the default `aws` provider.

#### M6: `ubuntu_pro` AMI Data Source Also Missing Provider

RESOLVED (confirmed in previous review): Same as M5.

#### M7: CloudFront Distribution Missing `comment`

FIXED (confirmed in previous review): `modules/cdn/main.tf:4` includes
`comment = "${var.cdn_hostname}.infrahouse.com CDN distribution"`.

#### M8: CDN Module Resource Names Could Be More Descriptive

FIXED: Resources have been renamed from `repo` to `this`:
- `aws_cloudfront_distribution.this` at `modules/cdn/main.tf:1`
- `aws_route53_record.this` at `modules/cdn/dns.tf:1`
- `aws_acm_certificate_validation.this` at `modules/cdn/ssl.tf:24`

This follows the coding standard: "Single resource of a type: use `this` or
`main`."

#### M9: Makefile Missing `clean` Target

FIXED (confirmed in previous review): `Makefile:62-65` includes a `clean`
target.

#### M10: Makefile `install-hooks` Uses Custom Symlink Instead of `pre-commit install`

FIXED (confirmed in previous review): `Makefile:27-28` uses `pre-commit install`.

---

### Low Severity

#### L1: Duplicate Default Provider and `aws-uw1` Alias

FIXED (confirmed in previous review): Single `aws` provider block in
`providers.tf`.

#### L2: Provider Tags Use Colon Syntax Instead of Equals

FIXED (confirmed in previous review): `providers.tf:8-9` uses `=` syntax.

#### L3: `cdn_hostname` Variable Missing Validation

STILL OPEN (informational): `modules/cdn/variables.tf:1-3` has `type` and
`description` but no `validation` block. Invalid hostnames would fail at apply
time rather than plan time. This is low severity since the variable is only
used within this root module with known-good values (`"cdn"` and
`"cdn-staging"`).

**File**: `modules/cdn/variables.tf:1-3`

**Recommendation**: Add validation when convenient:
```hcl
variable "cdn_hostname" {
  type        = string
  description = "Host part of the CDN full hostname."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cdn_hostname))
    error_message = "cdn_hostname must contain only lowercase letters, numbers, and hyphens."
  }
}
```

#### L4: CDN Module Name `cdn-staging` Uses Hyphen

FIXED: `cdn.tf:7` now reads `module "cdn_staging"` with underscore,
conforming to snake_case naming standards.

#### L5: README.md Is Outdated / Minimally Populated

FIXED (confirmed in previous review): README rewritten with proper content
and terraform-docs markers.

#### L6: `bootstrap-ci` Target Depends on `bootstrap`

Not addressed but acceptable: `Makefile:36` still has
`bootstrap-ci: bootstrap`, which installs hooks in CI. This is harmless
since `pre-commit` is in `requirements.txt` and hook installation will succeed.

#### L7: CloudFront Geo-Restriction Blacklist May Need Updating

FIXED (confirmed in previous review): `modules/cdn/variables.tf:6-10`
externalizes the list as a variable with default
`["BY", "CN", "IR", "RU"]`.

#### L8: No `required_version` in Root `terraform.tf`

FIXED (confirmed in previous review): `terraform.tf:2` reads
`required_version = "~> 1.14"`.

---

### Informational

#### I1: CI/CD Workflow Uses `actions/checkout@v5` and `aws-actions/configure-aws-credentials@v5`

Still present, still informational. Renovate excludes GitHub Actions from
auto-updates by design. No action needed.

#### I2: CI Runs on `ubuntu-latest` (Not Self-Hosted)

FIXED (confirmed in previous review): Both workflows use `runs-on: self-hosted`.

#### I3: CDN Module Hardcodes `infrahouse.com` Domain

Still present, still informational. Acceptable for a root infrastructure
module that is specific to infrahouse.com.

---

### Previously-New Issues

#### NEW-H1 (from Follow-Up #1): `cdn-logs.tf` Hardcodes S3 Bucket Name and Account ID

FIXED:
- `locals.tf:4` defines `cdn_logs_bucket_name = "infrahouse-cdn-access-logs"`
- `cdn-logs.tf:4` uses `local.cdn_logs_bucket_name` in the module call
- `cdn-logs.tf:18` uses `local.cdn_logs_bucket_name` in the bucket policy ARN
- `data_sources.tf:1` adds `data "aws_caller_identity" "current" {}`
- `cdn-logs.tf:22` uses `data.aws_caller_identity.current.account_id`

No more hardcoded duplication. The bucket name is defined once, and the
account ID comes from a data source.

#### NEW-M1 (from Follow-Up #1): CDN Module Uses `region` Attribute Instead of Provider Alias

Still present, still informational. The `region` attribute on
`aws_acm_certificate` and `aws_acm_certificate_validation` resources
(`modules/cdn/ssl.tf:2,25`) is a valid and simpler approach compared to
provider aliases. This eliminates the need for a separate `us-east-1`
provider block and `configuration_aliases`. No action needed.

---

## New Issues

#### NEW-L1: README.md Missing Trailing Newline

**Severity**: Low

**File**: `README.md` (last line)

The diff shows `\ No newline at end of file` for README.md. The coding
standard requires "All files must end with a newline character." All `.tf`
files now properly end with newlines, but README.md does not.

**Recommendation**: Add a trailing newline to README.md:
```bash
echo "" >> README.md
```

---

## Compliance Summary Against Coding Standards

| Standard | Status | Details |
|----------|--------|---------|
| **Variable type constraints** | PASS | All variables have explicit types |
| **Variable descriptions** | PASS | All variables have descriptions |
| **Variable validation** | PASS | `environment` and `tf_admin_arn` have validation |
| **Snake_case naming** | PASS | `cdn_staging` now uses underscore |
| **Resource naming (`this`)** | PASS | CDN module resources renamed to `this` |
| **Module version pinning** | PASS | Exact versions for registry modules |
| **InfraHouse registry** | PASS | All InfraHouse modules use `registry.infrahouse.com` |
| **Provider version constraint** | PASS | Root `~> 6.0`, CDN module `~> 6.0` |
| **`required_version`** | PASS | Both root (`~> 1.14`) and CDN module (`~> 1.14`) |
| **Encryption in transit** | PASS | TLSv1.2 only, `TLSv1.2_2021` viewer minimum |
| **Encryption at rest** | PASS | S3 state bucket uses encryption |
| **IAM least privilege** | PASS | `sts:GetCallerIdentity` only |
| **IAM policy document** | PASS | Uses `aws_iam_policy_document` data source |
| **Logging & auditing** | PASS | CloudFront access logs with 365-day retention |
| **Tagging** | PASS | `created_by` and `environment` in default_tags |
| **File organization** | PASS | Proper file structure in both root and CDN module |
| **DRY (locals)** | PASS | `cdn_logs_bucket_name` extracted to locals |
| **Data sources over hardcoding** | PASS | `aws_caller_identity` for account ID |
| **Makefile `help` default** | PASS | `.DEFAULT_GOAL := help` |
| **Makefile `bootstrap`** | PASS | Installs dependencies and hooks |
| **Makefile `install-hooks`** | PASS | Uses `pre-commit install` with commit-msg hook |
| **Makefile `clean`** | PASS | Target exists |
| **Makefile `lint`** | PASS | yamllint + terraform fmt check |
| **Makefile `format`** | PASS | terraform fmt recursive |
| **120 char line length** | PASS | No violations found |
| **Files end with newline** | PARTIAL | README.md missing trailing newline |
| **CI/CD self-hosted runner** | PASS | Both workflows use `self-hosted` |
| **CI/CD concurrency** | PASS | Concurrency group prevents parallel runs |
| **State management** | PASS | S3 + DynamoDB with encryption |
| **README documentation** | PASS | Proper content with terraform-docs markers |

---

## Remaining Recommendations Priority

### Should Fix (Quick Win)
1. **NEW-L1**: Add trailing newline to README.md

### Nice to Have (When Convenient)
2. **L3**: Add validation to `cdn_hostname` variable in `modules/cdn/variables.tf`

---

*Follow-up review #2 performed against InfraHouse CODING_STANDARD.md and
Terraform best practices. Compared against follow-up review #1 from 2026-03-21.*