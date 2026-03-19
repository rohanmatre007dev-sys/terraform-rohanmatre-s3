################################################################################
# Basic Example
# Simple private S3 bucket — most common pattern
#
# What gets created:
#   - 1 S3 bucket (private, all public access blocked)
#   - BucketOwnerEnforced ownership (ACLs disabled)
#   - No versioning (dev)
#   - No encryption (dev — override in prod)
#
# Auto-generated name: rohanmatre-dev-ap-south-1
# NOTE: Bucket names are GLOBALLY unique — this may conflict with existing buckets
################################################################################

provider "aws" {
  region = "ap-south-1"
}

module "s3" {
  source = "../../"

  environment = "dev"

  # All public access blocked by default ✅
  # BucketOwnerEnforced (ACLs disabled) by default ✅
  # Versioning off in dev (auto-on in prod) ✅
}
