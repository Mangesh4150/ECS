
region     = "ap-south-1"

#### Variables For Bastion-Server ####

instance_type_bastion = "t2.micro"
associate_public_ip   = true

#### storage-account ####
s3_bucket_name = "my-app-storage-bucket-484150"
environment    = "production"
enable_lock    = true

#### container-registry ####
registry_count = 2
registry_names = ["my-terraform-ecr", "my-terraform-ecr-2"]
tags = {
  Environment = "QA"
  Project     = "MyApp"
}
scan_on_push         = true
image_tag_mutability = "IMMUTABLE"
retention_days       = 30

#### ecs ####
cluster_name = "my-cluster"