# Global us-east-1: 변수 정의

variable "domain_name" {
  description = "메인 도메인 이름"
  type        = string
  default     = "mgz-g2-u3.shop"
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "subject_alternative_names" {
  description = "추가 SAN (Subject Alternative Names)"
  type        = list(string)
  default = [
    "*.mgz-g2-u3.shop",
    "dev.mgz-g2-u3.shop",
    "stage.mgz-g2-u3.shop",
    "mgz-g2-u3.shop"
  ]
}
