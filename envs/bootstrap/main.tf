# Bootstrap: Terraform tfstate 원격 저장소 설정
# jung-kyeol-bootstrap
#
# 이 모듈은 다음을 생성합니다:
# - S3 버킷: Terraform state 저장
# - DynamoDB 테이블: State locking
# - (선택) KMS 키: S3 버킷 암호화

locals {
  name_prefix     = "${var.owner_prefix}-${var.project_name}"
  state_bucket    = "${local.name_prefix}-tfstate-${var.aws_account_id}-${var.aws_region}"
  lock_table_name = "${local.name_prefix}-tfstate-lock"
  log_bucket      = "${local.name_prefix}-tfstate-logs-${var.aws_account_id}-${var.aws_region}"
}

# -----------------------------------------------------------------------------
# KMS Key for S3 Encryption (Optional)
# -----------------------------------------------------------------------------
resource "aws_kms_key" "tfstate" {
  count = var.enable_kms_encryption ? 1 : 0

  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-tfstate-kms"
  }
}

resource "aws_kms_alias" "tfstate" {
  count = var.enable_kms_encryption ? 1 : 0

  name          = "alias/${local.name_prefix}-tfstate"
  target_key_id = aws_kms_key.tfstate[0].key_id
}

# -----------------------------------------------------------------------------
# S3 Bucket for Terraform State
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "tfstate" {
  bucket = local.state_bucket

  # 삭제 방지: 실수로 버킷 삭제 방지
  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name        = local.state_bucket
    Purpose     = "terraform-state"
    Environment = "bootstrap"
  }
}

# 버저닝 활성화
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 서버 사이드 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms_encryption ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms_encryption ? aws_kms_key.tfstate[0].arn : null
    }
    bucket_key_enabled = var.enable_kms_encryption
  }
}

# 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 버킷 정책: HTTPS 강제
resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.tfstate.arn,
          "${aws_s3_bucket.tfstate.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# S3 Bucket for Access Logs (Optional but Recommended)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "tfstate_logs" {
  bucket = local.log_bucket

  tags = {
    Name        = local.log_bucket
    Purpose     = "terraform-state-access-logs"
    Environment = "bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 로그 버킷 라이프사이클: 90일 후 삭제
resource "aws_s3_bucket_lifecycle_configuration" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# tfstate 버킷에 로깅 활성화
resource "aws_s3_bucket_logging" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  target_bucket = aws_s3_bucket.tfstate_logs.id
  target_prefix = "tfstate-access-logs/"
}

# -----------------------------------------------------------------------------
# DynamoDB Table for State Locking
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Point-in-time recovery 활성화
  point_in_time_recovery {
    enabled = true
  }

  # 서버 사이드 암호화
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = local.lock_table_name
    Purpose     = "terraform-state-lock"
    Environment = "bootstrap"
  }
}
