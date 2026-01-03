# Bootstrap: 출력값 정의
# jung-kyeol-bootstrap

output "tfstate_bucket_name" {
  description = "Terraform state S3 버킷 이름"
  value       = aws_s3_bucket.tfstate.id
}

output "tfstate_bucket_arn" {
  description = "Terraform state S3 버킷 ARN"
  value       = aws_s3_bucket.tfstate.arn
}

output "tfstate_lock_table_name" {
  description = "Terraform state lock DynamoDB 테이블 이름"
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "tfstate_lock_table_arn" {
  description = "Terraform state lock DynamoDB 테이블 ARN"
  value       = aws_dynamodb_table.tfstate_lock.arn
}

output "kms_key_arn" {
  description = "KMS 키 ARN (암호화 활성화 시)"
  value       = var.enable_kms_encryption ? aws_kms_key.tfstate[0].arn : null
}

output "log_bucket_name" {
  description = "Access log S3 버킷 이름"
  value       = aws_s3_bucket.tfstate_logs.id
}

# 다른 환경에서 사용할 backend 설정 예시 출력
output "backend_config_example" {
  description = "다른 환경에서 사용할 backend.tf 설정 예시"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.tfstate.id}"
        key            = "<ENV>/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.tfstate_lock.name}"
        encrypt        = true
      }
    }
  EOT
}
