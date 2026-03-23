################################################################################
# General
################################################################################

variable "create_bucket" {
  description = "Controls whether S3 bucket and all resources will be created"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region where S3 bucket will be created"
  type        = string
  # default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "bucket" {
  description = "Name of the S3 bucket. Auto-generated if null. Must be globally unique."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "Creates a unique bucket name beginning with this prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags merged with common tags"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Delete all objects in bucket before destroying. Objects are NOT recoverable."
  type        = bool
  default     = false
}

variable "expected_bucket_owner" {
  description = "Account ID of the expected bucket owner for extra security"
  type        = string
  default     = null
}

variable "region_bucket" {
  description = "Region where the bucket is managed. Defaults to provider region."
  type        = string
  default     = null
}

################################################################################
# Access Control
# EXAM: S3 public access block = account/bucket level protection against public access
# EXAM: Block all public access = best practice for most buckets
# EXAM: ACLs are disabled by default (BucketOwnerEnforced) — use bucket policies instead
################################################################################

variable "acl" {
  description = "Canned ACL to apply. Conflicts with grant. Null recommended (use bucket policy)."
  type        = string
  default     = null
}

variable "grant" {
  description = "ACL policy grant. Conflicts with acl."
  type        = any
  default     = []
}

variable "owner" {
  description = "Bucket owner display name and ID. Conflicts with acl."
  type        = map(string)
  default     = {}
}

variable "block_public_acls" {
  description = "Block public ACLs for the bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs on the bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies"
  type        = bool
  default     = true
}

variable "skip_destroy_public_access_block" {
  description = "Skip destroying the public access block configuration when destroying bucket"
  type        = bool
  default     = true
}

################################################################################
# Object Ownership
# EXAM: BucketOwnerEnforced = ACLs disabled, bucket owner owns all objects (recommended)
# EXAM: ObjectWriter = uploader owns object
# EXAM: BucketOwnerPreferred = bucket owner gets ownership if uploaded with ACL
################################################################################

variable "control_object_ownership" {
  description = "Manage S3 Bucket Ownership Controls"
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "Object ownership: BucketOwnerEnforced (recommended), BucketOwnerPreferred, ObjectWriter"
  type        = string
  default     = "BucketOwnerEnforced"
}

################################################################################
# Versioning
# EXAM: Versioning = keeps all versions of every object
# EXAM: Required for MFA Delete and Cross-Region Replication
# EXAM: Once enabled, can only be suspended not disabled
# EXAM: Versioning doubles (or more) storage costs
################################################################################

variable "versioning" {
  description = "Versioning configuration. Use {enabled = true} to enable."
  type        = map(string)
  default     = {}
}

################################################################################
# Server-Side Encryption
# EXAM: SSE-S3 (AES-256) = AWS managed keys, free
# EXAM: SSE-KMS = customer managed keys, charged per API call
# EXAM: SSE-C = customer provided keys, managed outside AWS
# EXAM: Bucket key = reduces SSE-KMS API calls by 99% (cost saving)
################################################################################

variable "server_side_encryption_configuration" {
  description = "Server-side encryption configuration (SSE-S3 or SSE-KMS)"
  type        = any
  default     = {}
}

################################################################################
# Lifecycle Rules
# EXAM: Lifecycle rules = auto-transition or expire objects
# EXAM: Storage classes (cheapest to most expensive):
#   S3 Glacier Instant < Glacier Flexible < Glacier Deep Archive < S3 IA < S3 Standard
# EXAM: Minimum days before transitioning:
#   Standard-IA: 30 days minimum
#   Glacier: 90 days minimum
################################################################################

variable "lifecycle_rule" {
  description = "List of lifecycle rule maps for object transitions and expiration"
  type        = any
  default     = []
}

variable "transition_default_minimum_object_size" {
  description = "Default minimum object size for lifecycle transitions. Valid: all_storage_classes_128K, varies_by_storage_class"
  type        = string
  default     = null
}

################################################################################
# Bucket Policy
################################################################################

variable "attach_policy" {
  description = "Attach a custom bucket policy (set true to use policy variable)"
  type        = bool
  default     = false
}

variable "policy" {
  description = "Valid bucket policy JSON document"
  type        = string
  default     = null
}

variable "attach_public_policy" {
  description = "Attach user-defined public bucket policy"
  type        = bool
  default     = true
}

variable "attach_deny_insecure_transport_policy" {
  description = "Deny non-SSL (HTTP) transport to bucket — enforce HTTPS"
  type        = bool
  default     = false
}

variable "attach_require_latest_tls_policy" {
  description = "Require latest TLS version for bucket access"
  type        = bool
  default     = false
}

variable "attach_deny_unencrypted_object_uploads" {
  description = "Deny unencrypted object uploads to bucket"
  type        = bool
  default     = false
}

variable "attach_deny_incorrect_encryption_headers" {
  description = "Deny incorrect encryption headers on uploads"
  type        = bool
  default     = false
}

variable "attach_deny_incorrect_kms_key_sse" {
  description = "Deny usage of incorrect KMS key for SSE"
  type        = bool
  default     = false
}

variable "attach_deny_ssec_encrypted_object_uploads" {
  description = "Deny SSEC (customer-provided key) encrypted uploads"
  type        = bool
  default     = false
}

variable "allowed_kms_key_arn" {
  description = "ARN of KMS key allowed in PutObject (used with deny_incorrect_kms_key_sse)"
  type        = string
  default     = null
}

################################################################################
# Log Delivery Policies
# EXAM: S3 buckets can store logs from ELB, ALB, NLB, CloudTrail, WAF
################################################################################

variable "attach_elb_log_delivery_policy" {
  description = "Attach ELB access log delivery policy"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "Attach ALB/NLB log delivery policy"
  type        = bool
  default     = false
}

variable "attach_cloudtrail_log_delivery_policy" {
  description = "Attach CloudTrail log delivery policy"
  type        = bool
  default     = false
}

variable "attach_waf_log_delivery_policy" {
  description = "Attach WAF log delivery policy"
  type        = bool
  default     = false
}

variable "attach_access_log_delivery_policy" {
  description = "Attach S3 access log delivery policy"
  type        = bool
  default     = false
}

variable "access_log_delivery_policy_source_accounts" {
  description = "AWS Account IDs allowed to deliver access logs to this bucket"
  type        = list(string)
  default     = []
}

variable "access_log_delivery_policy_source_buckets" {
  description = "S3 bucket ARNs allowed to deliver access logs to this bucket"
  type        = list(string)
  default     = []
}

variable "access_log_delivery_policy_source_organizations" {
  description = "AWS Organization IDs allowed to deliver access logs"
  type        = list(string)
  default     = []
}

variable "lb_log_delivery_policy_source_organizations" {
  description = "AWS Organization IDs allowed to deliver ALB/NLB logs"
  type        = list(string)
  default     = []
}

################################################################################
# Logging
# EXAM: S3 access logging = track requests to bucket, stored in target bucket
################################################################################

variable "logging" {
  description = "Access logging configuration (target_bucket, target_prefix)"
  type        = any
  default     = {}
}

################################################################################
# CORS
# EXAM: CORS = Cross-Origin Resource Sharing — allows browser requests from other domains
# EXAM: Required for S3 static websites accessed from different domains
################################################################################

variable "cors_rule" {
  description = "List of CORS rule maps"
  type        = any
  default     = []
}

################################################################################
# Website Hosting
# EXAM: S3 static website hosting = host HTML/CSS/JS directly from S3
# EXAM: Requires public bucket + website configuration
# EXAM: Use CloudFront in front for HTTPS and performance
################################################################################

variable "website" {
  description = "Static website hosting or redirect configuration"
  type        = any
  default     = {}
}

################################################################################
# Replication
# EXAM: CRR (Cross-Region Replication) = replicate to different region
# EXAM: SRR (Same-Region Replication) = replicate within same region
# EXAM: Requires versioning enabled on both source and destination
################################################################################

variable "replication_configuration" {
  description = "Cross-Region Replication configuration"
  type        = any
  default     = {}
}

################################################################################
# Object Lock
# EXAM: Object Lock = WORM (Write Once Read Many) — prevents deletion/modification
# EXAM: Compliance mode = cannot be removed even by root user (for regulations)
# EXAM: Governance mode = can be removed by users with special permission
################################################################################

variable "object_lock_enabled" {
  description = "Enable S3 Object Lock (WORM). Cannot be disabled after enabling."
  type        = bool
  default     = false
}

variable "object_lock_configuration" {
  description = "Object lock configuration (mode, days, years)"
  type        = any
  default     = {}
}

################################################################################
# Acceleration
# EXAM: Transfer Acceleration = uses CloudFront edge locations for faster uploads
# EXAM: Good for large files uploaded from geographically dispersed locations
################################################################################

variable "acceleration_status" {
  description = "Transfer acceleration: Enabled or Suspended"
  type        = string
  default     = null
}

variable "request_payer" {
  description = "Who pays for data transfer: BucketOwner or Requester"
  type        = string
  default     = null
}

################################################################################
# Analytics + Inventory + Metrics + Intelligent Tiering
################################################################################

variable "analytics_configuration" {
  description = "Bucket analytics configuration"
  type        = any
  default     = {}
}

variable "analytics_self_source_destination" {
  description = "Whether analytics source and destination are the same bucket"
  type        = bool
  default     = false
}

variable "analytics_source_account_id" {
  description = "Analytics source account ID"
  type        = string
  default     = null
}

variable "analytics_source_bucket_arn" {
  description = "Analytics source bucket ARN"
  type        = string
  default     = null
}

variable "attach_analytics_destination_policy" {
  description = "Attach analytics destination policy"
  type        = bool
  default     = false
}

variable "inventory_configuration" {
  description = "S3 inventory configuration"
  type        = any
  default     = {}
}

variable "inventory_self_source_destination" {
  description = "Whether inventory source and destination are the same bucket"
  type        = bool
  default     = false
}

variable "inventory_source_account_id" {
  description = "Inventory source account ID"
  type        = string
  default     = null
}

variable "inventory_source_bucket_arn" {
  description = "Inventory source bucket ARN"
  type        = string
  default     = null
}

variable "attach_inventory_destination_policy" {
  description = "Attach inventory destination policy"
  type        = bool
  default     = false
}

variable "metric_configuration" {
  description = "Bucket metric configuration for CloudWatch"
  type        = any
  default     = []
}

variable "intelligent_tiering" {
  description = "Intelligent tiering configuration"
  type        = any
  default     = {}
}

################################################################################
# Directory Bucket (S3 Express One Zone)
# EXAM: Directory bucket = S3 Express One Zone — single AZ, 10x lower latency
################################################################################

variable "is_directory_bucket" {
  description = "Create a directory bucket (S3 Express One Zone)"
  type        = bool
  default     = false
}

variable "availability_zone_id" {
  description = "Availability Zone ID for directory bucket"
  type        = string
  default     = null
}

variable "location_type" {
  description = "Location type: AvailabilityZone or LocalZone"
  type        = string
  default     = null
}

variable "data_redundancy" {
  description = "Data redundancy. Valid values: SingleAvailabilityZone"
  type        = string
  default     = null
}

variable "type" {
  description = "Bucket type. Valid values: Directory"
  type        = string
  default     = "Directory"
}

################################################################################
# Metadata Configuration
################################################################################

variable "create_metadata_configuration" {
  description = "Create metadata configuration resource"
  type        = bool
  default     = false
}

variable "metadata_encryption_configuration" {
  description = "Encryption configuration for metadata"
  type        = any
  default     = null
}

variable "metadata_inventory_table_configuration_state" {
  description = "Inventory table state: ENABLED or DISABLED"
  type        = string
  default     = null
}

variable "metadata_journal_table_record_expiration" {
  description = "Journal table record expiration: ENABLED or DISABLED"
  type        = string
  default     = null
}

variable "metadata_journal_table_record_expiration_days" {
  description = "Days to retain journal table records"
  type        = number
  default     = null
}
