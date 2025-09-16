
provider "aws" {
  region = "ca-central-1"
}

# S3 bucket for static website
resource "aws_s3_bucket" "static_site" {
  bucket = "my-website-buckethello-12345"   # must be globally unique

  website {
    index_document = "index.html"
  
  }
}

# Public access block (allow policies, but not ACLs)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Public read policy
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

# Output website endpoint
output "website_url" {
  value = aws_s3_bucket.static_site.website_endpoint
}
