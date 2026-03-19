################################################################################
# S3 Bucket Core Outputs
################################################################################

output "s3_bucket_id" {
  description = "Name/ID of the S3 bucket — use as bucket name in AWS CLI/SDK"
  value       = module.s3.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the bucket (arn:aws:s3:::bucketname) — used in IAM policies"
  value       = module.s3.s3_bucket_arn
}

output "s3_bucket_region" {
  description = "AWS region where the bucket resides"
  value       = module.s3.s3_bucket_region
}

output "s3_bucket_tags" {
  description = "All tags assigned to the bucket"
  value       = module.s3.s3_bucket_tags
}

################################################################################
# Domain Names
# Consumed by: CloudFront origin, Route53 records, SDK endpoints
################################################################################

output "s3_bucket_bucket_domain_name" {
  description = "Bucket domain name (bucketname.s3.amazonaws.com) — for global access"
  value       = module.s3.s3_bucket_bucket_domain_name
}

output "s3_bucket_bucket_regional_domain_name" {
  description = "Region-specific domain name — use as CloudFront S3 origin to prevent redirects"
  value       = module.s3.s3_bucket_bucket_regional_domain_name
}

output "s3_bucket_hosted_zone_id" {
  description = "Route53 Hosted Zone ID for this bucket's region — used in Route53 alias records"
  value       = module.s3.s3_bucket_hosted_zone_id
}

################################################################################
# Versioning
################################################################################

output "aws_s3_bucket_versioning_status" {
  description = "Versioning status: Enabled, Suspended, or Disabled"
  value       = module.s3.aws_s3_bucket_versioning_status
}

################################################################################
# Policy + Lifecycle
################################################################################

output "s3_bucket_policy" {
  description = "Bucket policy JSON (empty string if no policy attached)"
  value       = module.s3.s3_bucket_policy
}

output "s3_bucket_lifecycle_configuration_rules" {
  description = "Lifecycle rules configured on the bucket (empty string if none)"
  value       = module.s3.s3_bucket_lifecycle_configuration_rules
}

################################################################################
# Website Outputs
# Consumed by: Route53 alias records for static website hosting
################################################################################

output "s3_bucket_website_endpoint" {
  description = "Website endpoint URL (empty if website hosting not configured)"
  value       = module.s3.s3_bucket_website_endpoint
}

output "s3_bucket_website_domain" {
  description = "Website domain for Route53 alias records (empty if not configured)"
  value       = module.s3.s3_bucket_website_domain
}

################################################################################
# Directory Bucket Outputs (S3 Express One Zone)
################################################################################

output "s3_directory_bucket_arn" {
  description = "ARN of the directory bucket (empty if not a directory bucket)"
  value       = module.s3.s3_directory_bucket_arn
}

output "s3_directory_bucket_name" {
  description = "Name of the directory bucket (empty if not a directory bucket)"
  value       = module.s3.s3_directory_bucket_name
}
