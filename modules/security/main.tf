# Security Module: WAFv2 and CloudFront
# Note: WAF for CloudFront MUST be in us-east-1

variable "name_prefix" {
  description = "Name prefix"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "origin_domain_name" {
  description = "ALB domain name (e.g., origin-dev-kyeol.msp-g1.click)"
  type        = string
}

# -----------------------------------------------------------------------------
# WAFv2 Web ACL (CloudFront)
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "cf" {
  name        = "${var.name_prefix}-cf-waf"
  description = "WAF for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # AWS Managed Rules (Core Rule Set)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-cf-waf-metric"
    sampled_requests_enabled   = true
  }
}

# -----------------------------------------------------------------------------
# CloudFront Distribution
# -----------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = var.origin_domain_name
    origin_id   = "ALBOrigin"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront for ${var.name_prefix}"
  default_root_object = ""

  web_acl_id = aws_wafv2_web_acl.cf.arn

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALBOrigin"

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0 # API/App 중심이므로 기본적으로 캐싱 끔
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # 실제 운영 시 ACM ARN 연결 필요
  }

  tags = var.tags
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

