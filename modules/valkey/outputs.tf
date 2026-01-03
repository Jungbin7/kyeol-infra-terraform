# Valkey (ElastiCache) Module: 출력값

output "cache_replication_group_id" {
  description = "ElastiCache 복제 그룹 ID"
  value       = aws_elasticache_replication_group.main.id
}

output "cache_replication_group_arn" {
  description = "ElastiCache 복제 그룹 ARN"
  value       = aws_elasticache_replication_group.main.arn
}

output "cache_endpoint" {
  description = "캐시 프라이머리 엔드포인트"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "cache_port" {
  description = "캐시 포트"
  value       = var.port
}

output "subnet_group_name" {
  description = "서브넷 그룹 이름"
  value       = aws_elasticache_subnet_group.main.name
}
