# EKS Module: 출력값

output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS 클러스터 이름"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS 클러스터 ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS 클러스터 API 엔드포인트"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 CA 인증서 (base64)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_version" {
  description = "EKS 클러스터 Kubernetes 버전"
  value       = aws_eks_cluster.main.version
}

# OIDC
output "cluster_oidc_issuer_url" {
  description = "EKS 클러스터 OIDC Issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.cluster[0].arn : null
}

# Node Group
output "node_group_id" {
  description = "노드 그룹 ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "노드 그룹 ARN"
  value       = aws_eks_node_group.main.arn
}

output "node_group_role_arn" {
  description = "노드 그룹 IAM 역할 ARN"
  value       = aws_iam_role.node_group.arn
}

# IRSA Roles
output "alb_controller_role_arn" {
  description = "AWS Load Balancer Controller IRSA 역할 ARN"
  value       = var.enable_alb_controller_irsa && var.enable_irsa ? aws_iam_role.alb_controller[0].arn : null
}

output "external_dns_role_arn" {
  description = "ExternalDNS IRSA 역할 ARN"
  value       = var.enable_external_dns_irsa && var.enable_irsa ? aws_iam_role.external_dns[0].arn : null
}

# Security Group
output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_security_group.cluster.id
}

# kubeconfig 명령어 예시
output "kubeconfig_command" {
  description = "kubeconfig 설정 명령어"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.id} --name ${aws_eks_cluster.main.name}"
}
