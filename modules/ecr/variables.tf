# ECR Module: 변수 정의

variable "name_prefix" {
  description = "리소스 이름 프리픽스 (예: jung-kyeol)"
  type        = string
}

variable "repository_names" {
  description = "생성할 ECR 리포지토리 이름 목록"
  type        = list(string)
  default     = ["api", "storefront", "dashboard"]
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능 여부 (MUTABLE 또는 IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "푸시 시 이미지 스캔 활성화"
  type        = bool
  default     = true
}

variable "lifecycle_policy_enabled" {
  description = "라이프사이클 정책 활성화"
  type        = bool
  default     = true
}

variable "lifecycle_max_image_count" {
  description = "유지할 최대 이미지 수"
  type        = number
  default     = 30
}

variable "tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}
