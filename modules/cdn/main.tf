resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.cdn_hostname}.infrahouse.com CDN distribution"
  aliases = [
    local.cdn_domain_name
  ]

  origin {
    domain_name = "infrahouse.com"
    origin_id   = local.origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "https-only"
    allowed_methods = [
      "GET", "HEAD"
    ]
    cached_methods = [
      "GET", "HEAD"
    ]
    cache_policy_id = aws_cloudfront_cache_policy.default.id
    compress        = true
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config {
    include_cookies = false
    bucket          = var.logging_bucket_domain_name
    prefix          = "cloudfront/${var.cdn_hostname}/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = var.geo_restriction_locations
    }
  }

}

resource "aws_cloudfront_cache_policy" "default" {
  name        = "${local.origin_id}_${var.cdn_hostname}"
  min_ttl     = 60
  default_ttl = 300
  max_ttl     = 600

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }

}
