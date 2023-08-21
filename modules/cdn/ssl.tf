resource "aws_acm_certificate" "cdn" {
  provider          = aws.ue1
  domain_name       = local.cdn_domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.ih_com.zone_id
  records = [
    each.value.record
  ]
  ttl = 60
}

resource "aws_acm_certificate_validation" "repo" {
  provider        = aws.ue1
  certificate_arn = aws_acm_certificate.cdn.arn
  validation_record_fqdns = [
    aws_route53_record.cert_validation[aws_acm_certificate.cdn.domain_name].fqdn
  ]
}
