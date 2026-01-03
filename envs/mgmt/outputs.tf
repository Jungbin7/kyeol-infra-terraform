# MGMT Environment: 출력값

# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID 목록"
  value       = module.vpc.public_subnet_ids
}

output "app_private_subnet_ids" {
  description = "App Private 서브넷 ID 목록"
  value       = module.vpc.app_private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway Public IP"
  value       = module.vpc.nat_gateway_public_ip
}

# EKS
output "eks_cluster_name" {
  description = "EKS 클러스터 이름"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS 클러스터 CA 인증서"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "alb_controller_role_arn" {
  description = "AWS Load Balancer Controller IRSA 역할 ARN"
  value       = module.eks.alb_controller_role_arn
}

output "external_dns_role_arn" {
  description = "ExternalDNS IRSA 역할 ARN"
  value       = module.eks.external_dns_role_arn
}

output "kubeconfig_command" {
  description = "kubeconfig 설정 명령어"
  value       = module.eks.kubeconfig_command
}

output "github_actions_role_arn" {
  description = "GitHub Actions용 IAM 역할 ARN"
  value       = module.github_oidc.github_actions_role_arn
}