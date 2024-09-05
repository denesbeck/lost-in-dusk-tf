resource "aws_route53_zone" "route53_zone" {
  name = "lostindusk.com"
}

resource "aws_route53_record" "route53_record_A" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "lostindusk.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "route53_record_NS" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "lostindusk.com"
  type    = "NS"
  ttl     = "172800"
  records = aws_route53_zone.route53_zone.name_servers
}

resource "aws_route53_record" "route53_record_SOA" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "lostindusk.com"
  type    = "SOA"
  ttl     = "900"
  records = [
    "ns-141.awsdns-17.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

resource "aws_route53_record" "route53_record_CNAME" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_be7c79af8993ef2f6be1202a42a76183.lostindusk.com"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "_a30cd712e7dbcea87be101f9aa47febd.sdgjtdhdhz.acm-validations.aws.",
  ]
}
