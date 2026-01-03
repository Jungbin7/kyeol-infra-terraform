# Bootstrap 환경

Terraform 원격 상태 저장소(S3 + DynamoDB)를 생성합니다.

## 생성 리소스

- **S3 버킷**: `jung-kyeol-tfstate-<account_id>-ap-northeast-1`
  - Terraform state 파일 저장
  - 버저닝 활성화
  - KMS 또는 AES256 암호화
  - HTTPS 강제 정책
- **S3 로그 버킷**: `jung-kyeol-tfstate-logs-<account_id>-ap-northeast-1`
  - state 버킷 액세스 로그 저장
  - 90일 후 자동 삭제
- **DynamoDB 테이블**: `jung-kyeol-tfstate-lock`
  - State locking 용도
  - Pay-per-request 모드
- **(선택) KMS 키**: `alias/jung-kyeol-tfstate`
  - S3 버킷 암호화용

## 사용 방법

```powershell
# 1. 변수 파일 복사 및 편집
Copy-Item terraform.tfvars.example terraform.tfvars
# terraform.tfvars의 aws_account_id를 실제 값으로 수정

# 2. 초기화
terraform init

# 3. 계획 확인
terraform plan

# 4. 적용
terraform apply -auto-approve

# 5. 출력값 확인 (다른 환경 backend 설정용)
terraform output backend_config_example
```

## 다음 단계

Bootstrap 완료 후, 다른 환경(dev, mgmt 등)의 `backend.tf`에 출력된 설정을 복사하여 사용합니다.
