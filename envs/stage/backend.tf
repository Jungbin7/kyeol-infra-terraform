# DEV Environment: S3 원격 백엔드
# Bootstrap에서 생성한 S3 버킷 사용

terraform {
  backend "s3" {
    bucket         = "jung-kyeol-tfstate-827913617839-ap-northeast-1"
    key            = "stage/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "jung-kyeol-tfstate-lock"
    encrypt        = true
  }
}
