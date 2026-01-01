# MGMT Environment: 변수 정의

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_account_id" {
  description = "AWS 계정 ID"
  type        = string
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "kyeol"
}

variable "owner_prefix" {
  description = "소유자 프리픽스"
  type        = string
  default     = "jung"
}

variable "environment" {
  description = "환경 이름"
  type        = string
  default     = "mgmt"
}

# VPC 설정
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.40.0.0/16"
}

variable "azs" {
  description = "가용영역 목록"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

# EKS 설정
variable "eks_cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_types" {
  description = "EKS 노드 인스턴스 타입"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "EKS 노드 희망 크기"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "EKS 노드 최소 크기"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "EKS 노드 최대 크기"
  type        = number
  default     = 3
}

# Route53
variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID (msp-g1.click)"
  type        = string
  default     = ""
}
