# KYEOL Infrastructure Terraform

KYEOL Saleor 멀티환경 AWS 인프라 IaC 레포지토리입니다.

## 디렉토리 구조

```
kyeol-infra-terraform/
├── envs/                    # 환경별 구성
│   ├── bootstrap/           # tfstate S3/DynamoDB (먼저 적용)
│   ├── dev/                 # DEV 환경 (Phase-1)
│   ├── mgmt/                # MGMT 환경 (Phase-1)
│   ├── stage/               # STAGE 템플릿 (Phase-2)
│   └── prod/                # PROD 템플릿 (Phase-2)
├── global/
│   └── us-east-1/           # CloudFront ACM (Phase-2)
└── modules/                 # 재사용 모듈
    ├── vpc/
    ├── eks/
    ├── rds_postgres/
    ├── valkey/
    └── ecr/
```

## 실행 순서 (Phase-1)

1. `envs/bootstrap` - tfstate 저장소 생성
2. `envs/mgmt` - MGMT VPC/EKS
3. `envs/dev` - DEV VPC/EKS/RDS/ECR

자세한 내용은 `docs/runbook-phase1-dev-mgmt.md`를 참조하세요.

## 네이밍 규칙

모든 리소스: `jung-kyeol-[env]-[resource]-[detail]`

예시:
- VPC: `jung-kyeol-dev-vpc`
- EKS: `jung-kyeol-dev-eks`
- RDS: `jung-kyeol-dev-rds`
