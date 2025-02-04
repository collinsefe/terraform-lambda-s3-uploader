# # This file contains the configuration for creating EC2 instances

resource "aws_s3_bucket" "foo" {
  bucket        = "mupando-lambda-s3-bucket-03022025"
  force_destroy = true
}


resource "aws_s3_bucket_public_access_block" "foo" {
  bucket = aws_s3_bucket.foo.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "foo" {
  bucket = aws_s3_bucket.foo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "foo" {
  depends_on = [
    aws_s3_bucket_ownership_controls.foo,
    aws_s3_bucket_public_access_block.foo,
  ]

  bucket = aws_s3_bucket.foo.id
  acl    = "public-read"
}


