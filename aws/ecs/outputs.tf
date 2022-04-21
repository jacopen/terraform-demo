output "lb_dns" {
  value = aws_lb.main.dns_name
}

output "cf_dns" {
  value = aws_cloudfront_distribution.main.domain_name
}
