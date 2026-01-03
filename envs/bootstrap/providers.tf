# Bootstrap: AWS Provider 설정
# jung-kyeol-bootstrap

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "kyeol"
      Environment = "bootstrap"
      ManagedBy   = "terraform"
      Owner       = "jung"
    }
  }
}
