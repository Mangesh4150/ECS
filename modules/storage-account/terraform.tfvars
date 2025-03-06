region                     = "ap-south-1"
s3_bucket_name             = "my-unique-s3-bucket-9975484150"
tags = {
  environment = "production"
  owner       = "dev-team"
  project     = "my-app"
}
block_public_acls          = true
block_public_policy        = true
ignore_public_acls         = true
restrict_public_buckets    = true
versioning_enabled         = true
enable_replication         = false
replication_destination_arn = ""  # Set this if replication is enabled
enable_lock                = false
