# Valkey (ElastiCache) Module: 변수 정의

variable "name_prefix" {
  description = "리소스 이름 프리픽스 (예: jung-kyeol-dev)"
  type        = string
}

variable "environment" {
  description = "환경 이름 (dev, stage, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "ElastiCache가 배치될 서브넷 ID 목록"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ElastiCache에 적용할 보안 그룹 ID 목록"
  type        = list(string)
}

# Cache 설정
variable "engine" {
  description = "캐시 엔진 (valkey 또는 redis)"
  type        = string
  default     = "valkey"
}

variable "engine_version" {
  description = "엔진 버전"
  type        = string
  default     = "7.2"
}

variable "node_type" {
  description = "노드 타입"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "캐시 노드 수"
  type        = number
  default     = 1
}

variable "port" {
  description = "포트 번호"
  type        = number
  default     = 6379
}

# 유지보수
variable "maintenance_window" {
  description = "유지보수 윈도우"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "snapshot_retention_limit" {
  description = "스냅샷 보존 기간 (일, 0=비활성화)"
  type        = number
  default     = 0
}

variable "tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}
