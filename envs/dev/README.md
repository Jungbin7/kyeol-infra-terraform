# DEV 환경

Phase-1 적용 대상 환경입니다.

## 리소스 구성

- **VPC**: `10.10.0.0/16` (단일 NAT Gateway)
- **EKS**: t3.medium × 2 노드
- **RDS**: db.t3.small, Single-AZ
- **Cache**: 없음 (DEV는 cache 미사용)

## 사전 요구사항

1. Bootstrap 환경이 완료되어 있어야 합니다.
2. `backend.tf`의 S3 버킷 이름을 실제 값으로 수정해야 합니다.

## 사용 방법

```powershell
# 1. 변수 파일 복사 및 편집
Copy-Item terraform.tfvars.example terraform.tfvars
# terraform.tfvars 편집 (aws_account_id, hosted_zone_id 등)

# 2. 초기화
terraform init

# 3. 계획 확인
terraform plan

# 4. 적용
terraform apply -auto-approve

# 5. kubeconfig 설정
aws eks update-kubeconfig --region ap-northeast-1 --name jung-kyeol-dev-eks
```
