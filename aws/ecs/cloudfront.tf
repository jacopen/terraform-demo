resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = false
  comment         = "cloudfront test"
 
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "jacopen-ecs"
 
    custom_origin_config {
      http_port                = 80
      https_port               = 5000
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "match-viewer"
      origin_read_timeout      = 60
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
 
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
 
  viewer_certificate {
    cloudfront_default_certificate = true
  }
 
  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "jacopen-ecs"
 
    forwarded_values {
      query_string = true
 
      cookies {
        forward = "all"
      }
 
      headers = ["Accept", "Accept-Language", "Authorization", "CloudFront-Forwarded-Proto", "Host", "Origin", "Referer", "User-agent"]
    }
 
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0
  }
}
