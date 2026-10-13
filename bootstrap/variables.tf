variable "project_id" {
  description = "GCP project that owns the Terraform state bucket."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique bucket name, e.g. '<project-id>-tfstate'."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][-_a-z0-9]{1,61}[a-z0-9]$", var.bucket_name)) && !strcontains(var.bucket_name, "goog")
    error_message = "bucket_name must be 3-63 lowercase letters, digits, '-' or '_', and must not contain 'goog'."
  }
}

variable "location" {
  description = "Bucket location. A region keeps state close to the infrastructure."
  type        = string
  default     = "asia-southeast2"
}

variable "state_writers" {
  description = "Map of state prefix => IAM member allowed to read/write it, e.g. { \"envs/dev\" = \"serviceAccount:github-terraform@my-project-id-dev.iam.gserviceaccount.com\" }. The service accounts must already exist."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.state_writers) : !startswith(k, "/") && !endswith(k, "/")])
    error_message = "State prefixes must not start or end with '/'."
  }
}
