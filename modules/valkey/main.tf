# Valkey (ElastiCache) Module: 메인 리소스
# AWS Valkey는 Replication Group API를 사용해야 합니다.

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.name_prefix}-cache"
  description                   = "Valkey replication group for ${var.name_prefix}"
  engine                        = var.engine
  engine_version                = var.engine_version
  node_type                     = var.node_type
  num_cache_clusters            = var.num_cache_nodes
  parameter_group_name          = "default.valkey7"
  port                          = var.port

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.security_group_ids

  automatic_failover_enabled = false # Single node dev 환경이므로 비활성화
  
  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cache"
  })
}
