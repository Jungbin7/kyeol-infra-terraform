# PROD Environment: 메인 모듈 구성
# Phase-2 적용 대상

locals {
  name_prefix  = "${var.owner_prefix}-${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"

  # PROD CIDR 설정 (사용자 지정: 2AZ, 4티어)
  public_subnet_cidrs       = ["10.30.0.0/24", "10.30.1.0/24"]
  app_private_subnet_cidrs  = ["10.30.4.0/22", "10.30.12.0/22"] 
  cache_private_subnet_cidrs = ["10.30.8.0/26", "10.30.8.64/26"]
  data_private_subnet_cidrs = ["10.30.9.0/24", "10.30.10.0/24"]
  pg_private_subnet_cidrs    = [] # PROD는 필요시 PG NAT 활성화

  tags = {
    Project     = "Kyeol-Migration"
    Environment = var.environment
    Owner       = "InfraTeam"
    Service     = "Commerce"
    ManagedBy   = "Terraform"
    ISMS-P      = "In-Scope"
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

  tags = local.tags
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

  tags = local.tags
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

  tags = local.tags
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

  tags = local.tags

  depends_on = [module.valkey] # 구축 순서 명시
}

# -----------------------------------------------------------------------------
# ECR Module
# -----------------------------------------------------------------------------
module "ecr" {
  source = "../../modules/ecr"

  name_prefix = "${var.owner_prefix}-${var.project_name}"

  repository_names = ["api", "storefront", "dashboard"]

  tags = local.tags
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
  tags        = local.tags

  # ACM 및 도메인 연결
  acm_certificate_arn = var.acm_certificate_arn_virginia
  domain_name         = var.domain_name
  
  # ExternalDNS로 생성될 오리진 도메인
  origin_domain_name = "origin-prod-kyeol.${var.domain_name}"
}
