variable "cdn_hostname" {
  type        = string
  description = "Host part of the CDN full hostname."
}

variable "geo_restriction_locations" {
  type        = list(string)
  description = "List of ISO 3166-1-alpha-2 country codes to blacklist."
  default     = ["BY", "CN", "IR", "RU"]
}

variable "logging_bucket_domain_name" {
  type        = string
  description = "S3 bucket domain name for CloudFront access logs."
}
