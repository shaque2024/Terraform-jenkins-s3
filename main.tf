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

# Public access block settings (allow policies, no ACLs)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false   # ✅ allow bucket policies
  restrict_public_buckets = false
}

# Public read bucket policy
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.static_site.id

  depends_on = [
    aws_s3_bucket_public_access_block.public_access
  ] # ✅ ensures block is updated first

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

# Output the static website URL
output "website_url" {
  value = aws_s3_bucket.static_site.website_endpoint
}

