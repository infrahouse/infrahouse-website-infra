resource "aws_route53_record" "repo" {
  name    = local.cdn_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.ih_com.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.repo.domain_name
    zone_id                = aws_cloudfront_distribution.repo.hosted_zone_id
  }
}
