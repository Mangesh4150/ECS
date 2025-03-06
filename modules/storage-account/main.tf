resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_public_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id
  role   = aws_iam_role.s3_replication_role[count.index].arn

  rule {
    id     = "cross-account-replication"
    status = "Enabled"

    destination {
      bucket        = var.replication_destination_arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "object_lock" {
  count  = var.enable_lock ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    default_retention {
      mode  = "GOVERNANCE"
      days  = 30
    }
  }
  depends_on = [aws_s3_bucket.s3_bucket] # Ensure versioning is enabled first
}

resource "aws_iam_role" "s3_replication_role" {
  count = var.enable_replication ? 1 : 0
  name  = "s3_replication_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}
