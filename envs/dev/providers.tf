# DEV Environment: AWS Provider 설정

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "kyeol"
      Environment = "dev"
      ManagedBy   = "terraform"
      Owner       = "jung"
    }
  }
}

# WAFv2 (CloudFront) 전용 프로바이더
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "kyeol"
      Environment = "dev"
      ManagedBy   = "terraform"
      Owner       = "jung"
    }
  }
}
