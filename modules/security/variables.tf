variable "acm_certificate_arn" {
  description = "ACM Certificate ARN (us-east-1)"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for CloudFront"
  type        = string
  default     = ""
}

