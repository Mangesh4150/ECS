module "vpc" {
  source = "./modules/vpc"
  #   access_key = var.access_key
  #   secret_key = var.secret_key
}

module "bastion-server" {
  source = "./modules/bastion-server"
  #   vpc_id  = module.vpc.vpc_id
  instance_type       = var.instance_type_bastion
  associate_public_ip = var.associate_public_ip
  security_group_id   = module.vpc.security_group_id
  subnet_id           = module.vpc.public_subnet_1
  #   ami                 = data.aws_ami.latest_ubuntu.id
  depends_on = [
    module.vpc
  ]
}

module "rds" {
  source = "./modules/rds"
  depends_on = [
  module.bastion-server]
}

module "storage-account" {
  source             = "./modules/storage-account"
  s3_bucket_name     = var.s3_bucket_name
  versioning_enabled = true
  enable_replication = false
  enable_lock        = var.enable_lock
  region             = var.region

  tags = {
    environment = var.environment
  }
}

module "ecr" {
  source               = "./modules/ecr"
  registry_count       = var.registry_count
  registry_names       = var.registry_names
  tags                 = var.tags
  scan_on_push         = var.scan_on_push
  image_tag_mutability = var.image_tag_mutability
  retention_days       = var.retention_days
}

resource "aws_ecs_cluster" "main_cluster" {
  name = var.cluster_name

  tags = {
    Name = var.cluster_name
  }
}

# locals {
#   services = {
#     app1 = "service1-ecr"
#     app2 = "service2-ecr"
#   }
# }

locals {
  services = {
    service1 = "service1-ecr"
    service2 = "service2-ecr"
  }
}

module "ecs_services" {
  for_each = local.services
  # for_each = local.ECS-services
  source       = "./modules/ecs"
  cluster_id   = aws_ecs_cluster.main_cluster.id # Correct reference to ECS cluster ID
  service_name = each.key                        # Pass each service name
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.private_subnets
  # image_url    = "${lookup(module.ecr.ecr_repository_urls, each.value)}:latest"
  image_url = "${lookup(module.ecr.ecr_repository_urls, each.key, "default-image")}:latest"

}

# module "ecs" {
#   source       = "./modules/ecs"
#   cluster_name = var.cluster_name
#   vpc_id       = module.vpc.vpc_id
#   # public_subnets = module.vpc.public_subnets
#   subnets = module.vpc.private_subnets # Pass the list of subnet IDs
#   # image_url = "${module.ecr.ecr_repository_urls}:latest"
#   image_url = "${module.ecr.ecr_repository_urls[0]}:latest"
# }

# module "ecs_app1" {
#   source       = "./modules/ecs"
#   cluster_name = var.cluster_name
#   vpc_id       = module.vpc.vpc_id
#   subnets      = module.vpc.private_subnets
#   image_url    = "${lookup(module.ecr.ecr_repository_urls, "service1-ecr")}:latest"
# }

# module "ecs_app2" {
#   source       = "./modules/ecs"
#   cluster_name = var.cluster_name
#   vpc_id       = module.vpc.vpc_id
#   subnets      = module.vpc.private_subnets
#   image_url    = "${lookup(module.ecr.ecr_repository_urls, "service2-ecr")}:latest"
# }


# module "ecs" {
#   source          = "./modules/ecs"
#   vpc_id          = module.vpc.vpc_id
#   subnet_id = module.vpc.private_subnet_1  # Use private subnets
#   ecr_repo_url    = module.ecr.repository_url
# }

