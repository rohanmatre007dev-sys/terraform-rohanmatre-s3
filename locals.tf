locals {
  ##############################################################################
  # Naming
  # Pattern: rohanmatre-{environment}-{region}-s3
  # Example: rohanmatre-dev-ap-south-1-s3
  # NOTE: S3 bucket names must be globally unique and lowercase
  #       Auto-name is a suggestion — pass bucket= for exact name
  ##############################################################################
  local_name = "rohanmatre-${var.environment}-${var.region}"
  bucket     = var.bucket == null ? local.local_name : var.bucket

  ##############################################################################
  # Environment-Aware Logic
  # EXAM: Prod S3 should always have:
  #   - Versioning enabled (point-in-time recovery)
  #   - Encryption enabled (data at rest protection)
  #   - Public access blocked (prevent accidental public exposure)
  #   - HTTPS enforced (data in transit protection)
  ##############################################################################
  is_prod = var.environment == "prod"

  # Versioning — auto-enable in prod
  versioning = local.is_prod && length(var.versioning) == 0 ? {
    enabled = true
  } : var.versioning

  # SSE-S3 encryption — auto-enable in prod if not configured
  server_side_encryption_configuration = local.is_prod && length(var.server_side_encryption_configuration) == 0 ? {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  } : var.server_side_encryption_configuration

  # Deny HTTP — enforce HTTPS in prod
  attach_deny_insecure_transport_policy = local.is_prod ? true : var.attach_deny_insecure_transport_policy

  # Deny unencrypted uploads — enforce in prod
  attach_deny_unencrypted_object_uploads = local.is_prod ? true : var.attach_deny_unencrypted_object_uploads

  # force_destroy — never in prod (protect data)
  force_destroy = local.is_prod ? false : var.force_destroy

  ##############################################################################
  # Common Tags
  ##############################################################################
  common_tags = {
    Environment = var.environment
    Owner       = "rohanmatre"
    GitHubRepo  = "terraform-rohanmatre-s3"
    ManagedBy   = "terraform"
  }

  tags = merge(local.common_tags, var.tags, { Name = local.bucket })
}
