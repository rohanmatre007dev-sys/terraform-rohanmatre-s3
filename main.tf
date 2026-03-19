################################################################################
# Wrapper calls the official upstream module
# Source: terraform-aws-modules/s3-bucket/aws
# Docs:   https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws
#
# This wrapper adds:
#   - Auto naming:          rohanmatre-{env}-{region} (globally unique pattern)
#   - Auto tagging:         Environment, Owner, GitHubRepo, ManagedBy
#   - Env-aware versioning: auto-enabled in prod
#   - Env-aware encryption: SSE-S3 auto-enabled in prod
#   - HTTPS enforcement:    deny HTTP transport auto-enabled in prod
#   - Upload encryption:    deny unencrypted uploads auto-enabled in prod
#   - force_destroy:        always false in prod (protect data)
#   - Public access block:  always on (all 4 settings)
################################################################################

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 5.9.0"

  ##############################################################################
  # General
  ##############################################################################
  bucket                = local.bucket
  bucket_prefix         = var.bucket_prefix
  create_bucket         = var.create_bucket
  expected_bucket_owner = var.expected_bucket_owner
  force_destroy         = local.force_destroy
  region                = var.region_bucket
  tags                  = local.tags

  ##############################################################################
  # Access Control — Public Access Block
  # EXAM: Block all 4 public access settings = S3 security best practice
  # EXAM: These settings exist at BOTH bucket and account level
  # EXAM: Account-level block overrides bucket-level settings
  ##############################################################################
  block_public_acls                = var.block_public_acls
  block_public_policy              = var.block_public_policy
  ignore_public_acls               = var.ignore_public_acls
  restrict_public_buckets          = var.restrict_public_buckets
  skip_destroy_public_access_block = var.skip_destroy_public_access_block

  ##############################################################################
  # ACL + Ownership
  # EXAM: BucketOwnerEnforced = ACLs disabled (AWS recommended since April 2023)
  # EXAM: Use bucket policies instead of ACLs for access control
  ##############################################################################
  acl                      = var.acl
  control_object_ownership = var.control_object_ownership
  grant                    = var.grant
  object_ownership         = var.object_ownership
  owner                    = var.owner

  ##############################################################################
  # Versioning
  # Auto-enabled in prod via locals
  # EXAM: Versioning = keeps multiple variants of every object
  # EXAM: Protects against accidental deletes and overwrites
  # EXAM: Once enabled, can only be suspended (not fully disabled)
  # EXAM: MFA Delete requires versioning enabled
  ##############################################################################
  versioning = local.versioning

  ##############################################################################
  # Server-Side Encryption
  # Auto-enabled (SSE-S3/AES256) in prod via locals
  # EXAM: SSE-S3  = S3 managed keys (free, default)
  # EXAM: SSE-KMS = KMS managed keys (charged, audit trail via CloudTrail)
  # EXAM: SSE-C   = customer provided keys (you manage outside AWS)
  # EXAM: bucket_key_enabled = reduces SSE-KMS costs by 99%
  ##############################################################################
  server_side_encryption_configuration = local.server_side_encryption_configuration

  ##############################################################################
  # Bucket Policies
  # EXAM: Bucket policies = JSON documents attached to bucket
  # EXAM: More flexible than ACLs — support conditions, IPs, VPC endpoints
  ##############################################################################
  attach_policy        = var.attach_policy
  attach_public_policy = var.attach_public_policy
  policy               = var.policy

  ##############################################################################
  # Security Policies
  # HTTPS + encryption enforcement auto-enabled in prod via locals
  # EXAM: Deny HTTP = forces all access via HTTPS (TLS)
  # EXAM: Deny unencrypted uploads = all objects must be encrypted at upload
  ##############################################################################
  allowed_kms_key_arn                       = var.allowed_kms_key_arn
  attach_deny_incorrect_encryption_headers  = var.attach_deny_incorrect_encryption_headers
  attach_deny_incorrect_kms_key_sse         = var.attach_deny_incorrect_kms_key_sse
  attach_deny_insecure_transport_policy     = local.attach_deny_insecure_transport_policy
  attach_deny_ssec_encrypted_object_uploads = var.attach_deny_ssec_encrypted_object_uploads
  attach_deny_unencrypted_object_uploads    = local.attach_deny_unencrypted_object_uploads
  attach_require_latest_tls_policy          = var.attach_require_latest_tls_policy

  ##############################################################################
  # Log Delivery Policies
  # EXAM: S3 can store logs from ELB, ALB, NLB, CloudTrail, WAF
  # EXAM: Log bucket needs specific bucket policy to accept logs
  ##############################################################################
  access_log_delivery_policy_source_accounts      = var.access_log_delivery_policy_source_accounts
  access_log_delivery_policy_source_buckets       = var.access_log_delivery_policy_source_buckets
  access_log_delivery_policy_source_organizations = var.access_log_delivery_policy_source_organizations
  attach_access_log_delivery_policy               = var.attach_access_log_delivery_policy
  attach_cloudtrail_log_delivery_policy           = var.attach_cloudtrail_log_delivery_policy
  attach_elb_log_delivery_policy                  = var.attach_elb_log_delivery_policy
  attach_lb_log_delivery_policy                   = var.attach_lb_log_delivery_policy
  attach_waf_log_delivery_policy                  = var.attach_waf_log_delivery_policy
  lb_log_delivery_policy_source_organizations     = var.lb_log_delivery_policy_source_organizations

  ##############################################################################
  # Lifecycle Rules
  # EXAM: Transition objects through storage classes to save cost
  # EXAM: Storage class cost order (low→high): Deep Archive < Glacier < IA < Standard
  # EXAM: Minimum days: Standard-IA=30, Glacier=90
  # EXAM: Expire (delete) old objects or non-current versions automatically
  ##############################################################################
  lifecycle_rule                         = var.lifecycle_rule
  transition_default_minimum_object_size = var.transition_default_minimum_object_size

  ##############################################################################
  # Access Logging
  # EXAM: S3 server access logging = requests logged to target bucket
  # EXAM: Different from CloudTrail (API-level) — this is object-level
  ##############################################################################
  logging = var.logging

  ##############################################################################
  # CORS
  # EXAM: CORS = allows browser JS from different origin to access bucket
  # EXAM: Required for S3 static websites with external API calls
  ##############################################################################
  cors_rule = var.cors_rule

  ##############################################################################
  # Static Website Hosting
  # EXAM: S3 website = HTTP only (not HTTPS) — put CloudFront in front for HTTPS
  # EXAM: Website endpoint format: bucket.s3-website-region.amazonaws.com
  # EXAM: Index document + error document required
  ##############################################################################
  website = var.website

  ##############################################################################
  # Cross-Region Replication
  # EXAM: CRR = automatic async replication to different region
  # EXAM: Requires versioning on source AND destination bucket
  # EXAM: Source and destination can be in different accounts
  # EXAM: Use for: DR, compliance, latency reduction
  ##############################################################################
  replication_configuration = var.replication_configuration

  ##############################################################################
  # Object Lock (WORM)
  # EXAM: WORM = Write Once Read Many
  # EXAM: Governance mode = privileged users can override retention
  # EXAM: Compliance mode = no one can override (even root) — regulatory use
  # EXAM: Must be enabled at bucket creation time
  ##############################################################################
  object_lock_configuration = var.object_lock_configuration
  object_lock_enabled       = var.object_lock_enabled

  ##############################################################################
  # Transfer Acceleration
  # EXAM: Transfer Acceleration = uses CloudFront edge locations for uploads
  # EXAM: Good for large files from geographically distributed locations
  ##############################################################################
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer

  ##############################################################################
  # Analytics + Inventory + Metrics + Intelligent Tiering
  ##############################################################################
  analytics_configuration             = var.analytics_configuration
  analytics_self_source_destination   = var.analytics_self_source_destination
  analytics_source_account_id         = var.analytics_source_account_id
  analytics_source_bucket_arn         = var.analytics_source_bucket_arn
  attach_analytics_destination_policy = var.attach_analytics_destination_policy
  attach_inventory_destination_policy = var.attach_inventory_destination_policy
  intelligent_tiering                 = var.intelligent_tiering
  inventory_configuration             = var.inventory_configuration
  inventory_self_source_destination   = var.inventory_self_source_destination
  inventory_source_account_id         = var.inventory_source_account_id
  inventory_source_bucket_arn         = var.inventory_source_bucket_arn
  metric_configuration                = var.metric_configuration

  ##############################################################################
  # Directory Bucket (S3 Express One Zone)
  # EXAM: Express One Zone = 10x lower latency, single AZ, higher throughput
  # EXAM: Not replicated across AZs — data loss risk if AZ fails
  ##############################################################################
  availability_zone_id = var.availability_zone_id
  data_redundancy      = var.data_redundancy
  is_directory_bucket  = var.is_directory_bucket
  location_type        = var.location_type
  type                 = var.type

  ##############################################################################
  # Metadata Configuration
  ##############################################################################
  create_metadata_configuration                 = var.create_metadata_configuration
  metadata_encryption_configuration             = var.metadata_encryption_configuration
  metadata_inventory_table_configuration_state  = var.metadata_inventory_table_configuration_state
  metadata_journal_table_record_expiration      = var.metadata_journal_table_record_expiration
  metadata_journal_table_record_expiration_days = var.metadata_journal_table_record_expiration_days
}
