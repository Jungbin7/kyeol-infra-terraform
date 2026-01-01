# MGMT Environment: S3 원격 백엔드

terraform {
  backend "s3" {
    bucket         = "jung-kyeol-tfstate" # 팀원별로 수정 필요
    key            = "mgmt/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "jung-kyeol-tfstate-lock"
    encrypt        = true
  }
}
