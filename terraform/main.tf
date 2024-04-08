resource "aws_s3_bucket" "my_aws_bucket_example02" {

  bucket = var.aws_bucket_name
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.my_aws_bucket_example02.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.my_aws_bucket_example02.id

  index_document {
    suffix = "home.html"
  }

  error_document {
    key = "resumeErrorFile.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.my_aws_bucket_example02.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.my_aws_bucket_example02.id

  acl        = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.site,
    aws_s3_bucket_public_access_block.site
  ]
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.my_aws_bucket_example02.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = [
          aws_s3_bucket.my_aws_bucket_example02.arn,
          "${aws_s3_bucket.my_aws_bucket_example02.arn}/*",
        ]
      },
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.site
  ]
}