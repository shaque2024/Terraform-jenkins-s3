provider "aws" {
  region = "ca-central-1"
}

# S3 bucket for static website
resource "aws_s3_bucket" "static_site" {
  bucket = "my-website-bucket-12345"   # Change to a globally unique name
  acl    = "public-read"

  website {
    index_document = "index.html"

  }
}

# Block all public access settings (must allow public for static website)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read policy
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action   = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

# Output website endpoint
output "website_url" {
  value = aws_s3_bucket.static_site.website_endpoint
}
