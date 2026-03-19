output "s3_bucket_id" { value = module.s3.s3_bucket_id }
output "s3_bucket_arn" { value = module.s3.s3_bucket_arn }
output "s3_bucket_region" { value = module.s3.s3_bucket_region }
output "s3_bucket_regional_domain_name" { value = module.s3.s3_bucket_bucket_regional_domain_name }
output "s3_bucket_hosted_zone_id" { value = module.s3.s3_bucket_hosted_zone_id }
output "aws_s3_bucket_versioning_status" { value = module.s3.aws_s3_bucket_versioning_status }
output "s3_bucket_lifecycle_rules" { value = module.s3.s3_bucket_lifecycle_configuration_rules }
output "s3_logs_bucket_id" { value = module.s3_logs.s3_bucket_id }
