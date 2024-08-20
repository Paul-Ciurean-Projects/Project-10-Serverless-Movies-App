###############################
# R53 and Certificate Manager #
###############################

resource "aws_route53_zone" "zone_p10" {
  name = var.domain_name
}

resource "aws_acm_certificate" "cert_p10" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  provider = aws.n-virginia

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert_p10.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = aws_route53_zone.zone_p10.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 60
  records = [each.value.resource_record_value]
}

resource "aws_acm_certificate_validation" "cert_validation_p10" {
  certificate_arn = aws_acm_certificate.cert_p10.arn
  provider = aws.n-virginia

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]

   depends_on = [aws_route53_record.cert_validation]
}


##############
# CloudFront #
##############

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "movies-oac"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  origin_access_control_origin_type = "s3"
}

resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "myS3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "My CloudFront Distribution"
  default_root_object = "index.html"

  aliases = ["www.${var.domain_name}", "${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert_p10.arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [aws_acm_certificate_validation.cert_validation_p10]
}

resource "aws_route53_record" "records_for_cf" {
  zone_id = aws_route53_zone.zone_p10.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.my_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.my_distribution.hosted_zone_id
    evaluate_target_health = true
  }

  depends_on = [ aws_cloudfront_distribution.my_distribution ]
}

resource "aws_route53_record" "records_for_cf_www" {
  zone_id = aws_route53_zone.zone_p10.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.my_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.my_distribution.hosted_zone_id
    evaluate_target_health = true
  }

  depends_on = [ aws_cloudfront_distribution.my_distribution ]
}

output "aws_cloudfront_distribution" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
}