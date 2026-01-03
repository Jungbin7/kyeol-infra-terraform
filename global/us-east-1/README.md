# Global us-east-1: CloudFront ACM 인증서

CloudFront 배포에 사용할 ACM 인증서를 생성합니다.

> **중요**: CloudFront 인증서는 반드시 **us-east-1** 리전에서 생성해야 합니다.

## Phase-1 상태

- **미적용**: 이 리소스는 Phase-1에서 생성하지 않습니다.
- Phase-2에서 CloudFront 배포 시 함께 적용합니다.

## 인증서 구성

- 도메인: `mgz-g2-u3.shop`
- SAN:
  - `*.mgz-g2-u3.shop`
  - `dev.mgz-g2-u3.shop`
  - `stage.mgz-g2-u3.shop`
  - `mgz-g2-u3.shop`

## 사용 방법

```powershell
# 1. 변수 파일 생성
# terraform.tfvars에 hosted_zone_id 입력

# 2. 초기화 및 적용
terraform init
terraform plan
terraform apply -auto-approve
```
