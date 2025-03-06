variable "region" {}
variable "s3_bucket_name" {}
variable "tags" { type = map(string) }
variable "block_public_acls" { default = true }
variable "block_public_policy" { default = true }
variable "ignore_public_acls" { default = true }
variable "restrict_public_buckets" { default = true }
variable "versioning_enabled" { default = true }
variable "enable_replication" { default = false }
variable "replication_destination_arn" { default = "" }
variable "enable_lock" { default = false }
