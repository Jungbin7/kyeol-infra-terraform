# STAGE Environment: 메인 모듈 구성
# Phase-2 적용 대상

locals {
  name_prefix  = "${var.owner_prefix}-${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"

  # STAGE CIDR 설정 (Tokyo 리전 기준) - 10.20.x.x 대역
  public_subnet_cidrs       = ["10.20.0.0/24", "10.20.1.0/24"]
  app_private_subnet_cidrs  = ["10.20.4.0/22", "10.20.8.0/22"] 
  pg_private_subnet_cidrs   = ["10.20.12.0/24"]
  cache_private_subnet_cidrs = ["10.20.13.0/24", "10.20.14.0/24"]
  data_private_subnet_cidrs = ["10.20.16.0/24", "10.20.17.0/24"]

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner_prefix
    ManagedBy   = "terraform"
    ISMS_Scope  = "True"
  }
}

# -----------------------------------------------------------------------------
# VPC Module
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  name_prefix  = local.name_prefix
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs

  public_subnet_cidrs        = local.public_subnet_cidrs
  app_private_subnet_cidrs   = local.app_private_subnet_cidrs
  data_private_subnet_cidrs  = local.data_private_subnet_cidrs
  cache_private_subnet_cidrs = local.cache_private_subnet_cidrs
  pg_private_subnet_cidrs    = local.pg_private_subnet_cidrs

  enable_nat_gateway   = true
  enable_pg_nat        = false
  single_nat_gateway   = true
  enable_vpc_endpoints = true

  eks_cluster_name = local.cluster_name

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# EKS Module
# -----------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  name_prefix     = local.name_prefix
  environment     = var.environment
  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.app_private_subnet_ids

  # Node Group
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size

  # IRSA
  enable_irsa                 = true
  enable_alb_controller_irsa  = true
  enable_external_dns_irsa    = true
  external_dns_hosted_zone_id = var.hosted_zone_id

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Valkey (ElastiCache) Module - RDS보다 먼저 생성 권장
# -----------------------------------------------------------------------------
module "valkey" {
  source = "../../modules/valkey"

  name_prefix = local.name_prefix
  environment = var.environment

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.cache_private_subnet_ids
  
  # 보안 그룹: 일단 전체 허용 (테스트용)
  security_group_ids = [module.vpc.cache_security_group_id]

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# RDS PostgreSQL Module
# -----------------------------------------------------------------------------
module "rds" {
  source = "../../modules/rds_postgres"

  name_prefix = local.name_prefix
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.data_private_subnet_ids
  security_group_ids = module.vpc.rds_security_group_id != null ? [module.vpc.rds_security_group_id] : []

  instance_class = var.rds_instance_class
  multi_az       = var.rds_multi_az

  # DEV 설정
  deletion_protection = false
  skip_final_snapshot = true
  
  # 암호화 추가 (ISMS-P)
  storage_encrypted   = true

  tags = local.common_tags

  depends_on = [module.valkey] # 구축 순서 명시
}

# -----------------------------------------------------------------------------
# ECR Module
# -----------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  name_prefix = "${var.owner_prefix}-${var.project_name}"

  repository_names = ["api", "storefront", "dashboard"]

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Security Module (WAFv2 & CloudFront)
# -----------------------------------------------------------------------------
module "security" {
  source = "../../modules/security"
  
  providers = {
    aws = aws.us_east_1 # WAFv2 CloudFront scope는 반드시 us-east-1
  }

  name_prefix = local.name_prefix
  tags        = local.common_tags

  # ACM 및 도메인 연결
  acm_certificate_arn = var.acm_certificate_arn_virginia
  domain_name         = var.domain_name
  
  # ExternalDNS로 생성될 오리진 도메인
  origin_domain_name = "origin-stage-kyeol.${var.domain_name}"
}
