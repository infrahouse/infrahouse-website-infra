variable "environment" {
  type        = string
  description = "Environment name (production, staging, development, etc.)"

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.environment))
    error_message = "environment must contain only lowercase letters, numbers, and underscores. Got: ${var.environment}"
  }
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name in org/repo format (used for created_by tag)."
}

variable "tf_admin_arn" {
  type        = string
  description = "ARN of the IAM role to assume for Terraform administrative operations."

  validation {
    condition     = can(regex("^arn:aws:iam::", var.tf_admin_arn))
    error_message = "tf_admin_arn must be a valid IAM ARN. Got: ${var.tf_admin_arn}"
  }
}
