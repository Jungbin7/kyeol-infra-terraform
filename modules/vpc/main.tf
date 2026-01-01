# VPC Module: 메인 리소스 정의
# VPC, 서브넷 생성

locals {
  # AZ 수
  az_count = length(var.azs)

  # AZ 식별자 (a, c 등)
  az_suffixes = [for az in var.azs : substr(az, -1, 1)]

  # EKS 태그 (클러스터 이름이 제공된 경우)
  eks_shared_tag = var.eks_cluster_name != "" ? {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  } : {}

  eks_elb_tag = var.eks_cluster_name != "" ? {
    "kubernetes.io/role/elb" = "1"
  } : {}

  eks_internal_elb_tag = var.eks_cluster_name != "" ? {
    "kubernetes.io/role/internal-elb" = "1"
  } : {}
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, local.eks_shared_tag, {
    Name = "${var.name_prefix}-vpc"
  })
}

# -----------------------------------------------------------------------------
# Public Subnets
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index % local.az_count]
  map_public_ip_on_launch = true

  tags = merge(var.tags, local.eks_shared_tag, local.eks_elb_tag, {
    Name = "${var.name_prefix}-sub-pub-${local.az_suffixes[count.index % local.az_count]}"
    Tier = "public"
  })
}

# -----------------------------------------------------------------------------
# App Private Subnets
# -----------------------------------------------------------------------------
resource "aws_subnet" "app_private" {
  count = length(var.app_private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % local.az_count]

  tags = merge(var.tags, local.eks_shared_tag, local.eks_internal_elb_tag, {
    Name = "${var.name_prefix}-sub-app-${local.az_suffixes[count.index % local.az_count]}"
    Tier = "app-private"
  })
}

# -----------------------------------------------------------------------------
# Data Private Subnets (RDS 등)
# -----------------------------------------------------------------------------
resource "aws_subnet" "data_private" {
  count = length(var.data_private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.data_private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % local.az_count]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sub-data-${local.az_suffixes[count.index % local.az_count]}"
    Tier = "data-private"
  })
}

# -----------------------------------------------------------------------------
# Cache Private Subnets (Valkey/Redis, DEV는 생략)
# -----------------------------------------------------------------------------
resource "aws_subnet" "cache_private" {
  count = length(var.cache_private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cache_private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % local.az_count]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sub-cache-${local.az_suffixes[count.index % local.az_count]}"
    Tier = "cache-private"
  })
}

# -----------------------------------------------------------------------------
# PG Private Subnets (결제 API용 고정 IP 서브넷)
# -----------------------------------------------------------------------------
resource "aws_subnet" "pg_private" {
  count = length(var.pg_private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.pg_private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % local.az_count]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sub-pg-${local.az_suffixes[count.index % local.az_count]}"
    Tier = "pg-private"
  })
}