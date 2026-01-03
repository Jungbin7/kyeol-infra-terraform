# MGMT 환경

Phase-1 적용 대상 환경입니다. ArgoCD 및 중앙 모니터링 용도입니다.

## 리소스 구성

- **VPC**: `10.40.0.0/16` (단일 NAT Gateway)
- **EKS**: t3.medium × 2 노드
- **RDS/Cache**: 없음 (CI/CD 전용)

## 주요 역할

- ArgoCD 설치 (중앙 CD)
- 관측성 도구 (Prometheus/Grafana/Loki)
- 다른 환경(DEV/STAGE/PROD) 클러스터 관리

## 사용 방법

```powershell
# 1. 변수 파일 복사 및 편집
Copy-Item terraform.tfvars.example terraform.tfvars

# 2. 초기화
terraform init

# 3. 계획 확인
terraform plan

# 4. 적용
terraform apply -auto-approve

# 5. kubeconfig 설정
aws eks update-kubeconfig --region ap-northeast-1 --name jung-kyeol-mgmt-eks
```
