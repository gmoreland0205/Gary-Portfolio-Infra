data "aws_wafv2_web_acl" "waf" {
  name  = "cloudfront-waf-gary-infra"
  scope = "CLOUDFRONT"
}

#######################################
# S3 Bucket
#######################################

resource "aws_s3_bucket" "resume_files_bucket" {
  bucket = "resume-files-${var.project_name}"
}

locals {
  files = fileset("${path.module}/files", "**")
}

resource "aws_s3_object" "uploads" {
  for_each = local.files

  bucket = aws_s3_bucket.resume_files_bucket.id
  key    = "files/${each.value}"
  source = "${path.module}/files/${each.value}"

  content_type = "application/pdf"
  content_disposition = "attachment; filename=\"${basename(each.value)}\""
  etag = filemd5("${path.module}/files/${each.value}")
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.resume_files_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

#######################################
# CloudFront Distribution
#######################################

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac-${var.project_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront" {
  comment = "CloudFront to an WAF and then to S3 Bucket"
  origin {
    domain_name = aws_s3_bucket.resume_files_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled = true

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = data.aws_wafv2_web_acl.waf.arn
  
  tags = {
    Project = var.project_name
    Name = "cloudfront-${var.project_name}"
  }
  
}