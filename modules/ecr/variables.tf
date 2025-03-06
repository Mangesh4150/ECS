variable "registry_count" {
  description = "Number of ECR repositories to create"
  type        = number
  default     = 1
}

variable "registry_names" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "tags" {
  description = "Tags to assign to the ECR repositories"
  type        = map(string)
  default     = {}
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"
}

variable "retention_days" {
  description = "Number of days to retain untagged images before deletion"
  type        = number
  default     = 30
}
