# VPC Module: Security Groups (기본)

# -----------------------------------------------------------------------------
# Default VPC Security Group (제한적)
# -----------------------------------------------------------------------------
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # 기본 규칙 모두 삭제 (보안 강화)
  # ingress, egress 없음

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-default-restricted"
  })
}

# -----------------------------------------------------------------------------
# ALB Security Group (Ingress에서 사용)
# 참고: AWS LBC가 자동 생성하므로 이 SG는 선택적
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-sg-alb"
  description = "Security group for ALB (managed by AWS LBC)"
  vpc_id      = aws_vpc.main.id

  # HTTPS 인바운드
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP 인바운드 (리다이렉트용)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 모든 아웃바운드
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-alb"
  })
}

# -----------------------------------------------------------------------------
# RDS Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  count = length(var.data_private_subnet_cidrs) > 0 ? 1 : 0

  name        = "${var.name_prefix}-sg-rds"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  # PostgreSQL 인바운드 (전체 허용 - 테스트용)
  ingress {
    description = "PostgreSQL from anywhere (Testing)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 없음 (RDS는 외부 통신 불필요)

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-rds"
  })
}

# -----------------------------------------------------------------------------
# Cache (Valkey/Redis) Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "cache" {
  count = length(var.cache_private_subnet_cidrs) > 0 ? 1 : 0

  name        = "${var.name_prefix}-sg-cache"
  description = "Security group for ElastiCache Valkey/Redis"
  vpc_id      = aws_vpc.main.id

  # Redis 인바운드 (전체 허용 - 테스트용)
  ingress {
    description = "Redis from anywhere (Testing)"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-cache"
  })
}
