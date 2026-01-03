# Bootstrap: 변수 정의
# jung-kyeol-bootstrap

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_account_id" {
  description = "AWS 계정 ID (S3 버킷 네이밍에 사용)"
  type        = string
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "kyeol"
}

variable "owner_prefix" {
  description = "소유자 프리픽스 (jung-)"
  type        = string
  default     = "jung"
}

variable "enable_kms_encryption" {
  description = "tfstate S3 버킷 KMS 암호화 활성화 여부"
  type        = bool
  default     = true
}
