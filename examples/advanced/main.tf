################################################################################
# Advanced Example
# Production-grade S3 with versioning, KMS encryption, lifecycle, access logging
#
# What gets created:
#   - 1 prod S3 bucket (main data bucket)
#   - 1 logs S3 bucket (stores access logs from main bucket)
#   - Versioning (auto in prod via locals)
#   - SSE-KMS encryption (overrides prod default SSE-S3)
#   - Lifecycle rules (transition old versions to cheaper storage)
#   - Access logging to logs bucket
#   - HTTPS enforcement (auto in prod via locals)
#   - Deny unencrypted uploads (auto in prod via locals)
#   - force_destroy=false (auto in prod — protects data)
################################################################################

provider "aws" {
  region = "ap-south-1"
}

# Logs bucket — stores access logs from main bucket
module "s3_logs" {
  source = "../../"

  bucket      = "rohanmatre-prod-access-logs"
  environment = "prod"

  # Allow ELB/ALB to deliver logs here
  attach_elb_log_delivery_policy = true
  attach_lb_log_delivery_policy  = true

  force_destroy = true # logs bucket can be destroyed

  tags = { Purpose = "access-logs" }
}

# Main data bucket
module "s3" {
  source = "../../"

  bucket      = "rohanmatre-prod-data"
  environment = "prod"

  # KMS encryption — overrides prod default SSE-S3
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "alias/rohanmatre-prod-s3-key"
      }
      bucket_key_enabled = true # reduces KMS API costs by 99%
    }
  }

  # Lifecycle — transition old objects to cheaper storage
  lifecycle_rule = [
    {
      id      = "transition-old-versions"
      enabled = true

      # Transition current objects after 30 days
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      # Clean up old non-current versions
      noncurrent_version_transition = [
        {
          noncurrent_days = 30
          storage_class   = "STANDARD_IA"
        }
      ]

      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    }
  ]

  # Access logging → logs bucket
  logging = {
    target_bucket = module.s3_logs.s3_bucket_id
    target_prefix = "s3-access-logs/"
  }

  # CORS — allow access from your web app domain
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://app.rohanmatre.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  # Prod auto-sets:
  # versioning = { enabled = true }
  # attach_deny_insecure_transport_policy = true (HTTPS only)
  # attach_deny_unencrypted_object_uploads = true
  # force_destroy = false (data protection)

  tags = {
    Project    = "rohanmatre-platform"
    DataClass  = "confidential"
    CostCenter = "engineering"
  }
}
