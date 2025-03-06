registry_count = 2
registry_names = ["service1-ecr", "service2-ecr"]
tags = {
  Environment = "QA"
  Project     = "MyApp"
}
scan_on_push         = true
image_tag_mutability = "IMMUTABLE"
retention_days       = 60