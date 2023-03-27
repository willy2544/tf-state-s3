resource "random_id" "s3-suffix" {
  byte_length = 5
}

resource "aws_s3_bucket" "state-s3" {
  bucket = "terraform-state-bucket-${random_id.s3-suffix.hex}"
}

resource "aws_s3_bucket_acl" "state-s3" {
  bucket = aws_s3_bucket.state-s3.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state-s3" {
  bucket = aws_s3_bucket.state-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "state-s3" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state-s3" {
  bucket = aws_s3_bucket.state-s3.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state-s3.arn
      sse_algorithm     = "aws:kms" 
    }
  }
}

resource "aws_dynamodb_table" "terraform-locks" {
    hash_key = "LockID"
    name = "terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    attribute {
        name = "LockID"
        type = "S"
    }

    server_side_encryption {
        enabled     = true
        kms_key_arn = aws_kms_key.state-s3.arn
    }
}

