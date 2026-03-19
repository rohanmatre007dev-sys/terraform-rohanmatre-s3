# terraform-rohanmatre-s3

Terraform wrapper module for AWS S3 Bucket — built on top of [terraform-aws-modules/s3-bucket/aws](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws).

This wrapper adds:
- **Auto naming** → `rohanmatre-{environment}-{region}` (globally unique pattern)
- **Auto tagging** → `Environment`, `Owner`, `GitHubRepo`, `ManagedBy`
- **Env-aware versioning** → auto-enabled in prod
- **Env-aware encryption** → SSE-S3 (AES256) auto-enabled in prod
- **HTTPS enforcement** → deny HTTP transport auto-enabled in prod
- **Upload encryption** → deny unencrypted uploads auto-enabled in prod
- **Data protection** → `force_destroy=false` always in prod
- **Public access block** → all 4 settings always on

---

## Usage

### Basic (dev)

```hcl
module "s3" {
  source  = "rohanmatre007dev-sys/s3/rohanmatre"
  version = "1.0.0"

  environment = "dev"
}
```

### Advanced (prod with KMS + lifecycle)

```hcl
module "s3" {
  source  = "rohanmatre007dev-sys/s3/rohanmatre"
  version = "1.0.0"

  bucket      = "my-prod-data-bucket"
  environment = "prod"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "alias/my-key"
      }
      bucket_key_enabled = true
    }
  }

  lifecycle_rule = [{
    id      = "archive-old"
    enabled = true
    transition = [
      { days = 30,  storage_class = "STANDARD_IA" },
      { days = 90,  storage_class = "GLACIER" }
    ]
  }]
}
```

---

## Environment-Aware Behavior

| Setting | dev / stage | prod |
|---|---|---|
| Versioning | Off by default | Auto-enabled |
| Encryption | Off by default | Auto: SSE-S3 AES256 |
| HTTPS only | Off by default | Auto-enforced |
| Deny unencrypted uploads | Off by default | Auto-enforced |
| force_destroy | User-defined | Always false (data protection) |
| Public access block | Always on | Always on |

---

## S3 Storage Classes (EXAM)

| Class | Use Case | Min Duration |
|---|---|---|
| S3 Standard | Frequent access | None |
| S3 Intelligent-Tiering | Unknown access pattern | None |
| S3 Standard-IA | Infrequent access | 30 days |
| S3 One Zone-IA | Infrequent, single AZ | 30 days |
| S3 Glacier Instant | Archive, instant retrieval | 90 days |
| S3 Glacier Flexible | Archive, minutes-hours | 90 days |
| S3 Glacier Deep Archive | Long-term archive | 180 days |

---

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `create_bucket` | Controls whether bucket will be created | `bool` | `true` |
| `region` | AWS region | `string` | `"ap-south-1"` |
| `environment` | Environment: dev, stage, prod | `string` | `"dev"` |
| `bucket` | Bucket name. Auto-generated if null. Must be globally unique. | `string` | `null` |
| `versioning` | Versioning config. Auto-enabled in prod. | `map(string)` | `{}` |
| `server_side_encryption_configuration` | SSE config. Auto SSE-S3 in prod. | `any` | `{}` |
| `lifecycle_rule` | Lifecycle rules for transitions/expiration | `any` | `[]` |
| `logging` | Access logging config (target_bucket, prefix) | `any` | `{}` |
| `cors_rule` | CORS rules | `any` | `[]` |
| `replication_configuration` | Cross-region replication config | `any` | `{}` |
| `object_lock_enabled` | Enable WORM protection | `bool` | `false` |
| `force_destroy` | Delete all objects on destroy (always false in prod) | `bool` | `false` |
| `tags` | Additional tags | `map(string)` | `{}` |

Full list: [variables.tf](variables.tf)

---

## Outputs

| Name | Description | Consumed By |
|---|---|---|
| `s3_bucket_id` | Bucket name | AWS CLI, SDK, other modules |
| `s3_bucket_arn` | Bucket ARN | IAM policies |
| `s3_bucket_bucket_regional_domain_name` | Regional domain | CloudFront origin |
| `s3_bucket_hosted_zone_id` | Route53 zone ID | Route53 alias records |
| `aws_s3_bucket_versioning_status` | Versioning status | Reference |
| `s3_bucket_website_endpoint` | Website endpoint | Route53, testing |

Full list: [outputs.tf](outputs.tf)

---

## Notes

- Auto-generates bucket name as `rohanmatre-{environment}-{region}` — pass `bucket=` for exact name
- S3 bucket names are **globally unique** — may conflict with existing buckets
- Upstream module: [terraform-aws-modules/s3-bucket/aws >= 6.28](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws)
- Default region: `ap-south-1`

---

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.5.7 |
| aws | >= 6.28 |
