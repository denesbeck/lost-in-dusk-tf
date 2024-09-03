resource "aws_acm_certificate" "acm_certificate" {
  provider          = aws.n_virginia
  domain_name       = "lostindusk.com"
  validation_method = "DNS"
}
