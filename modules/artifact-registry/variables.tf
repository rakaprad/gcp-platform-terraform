variable "project_id" {
  description = "GCP project ID to create the repository in."
  type        = string
}

variable "location" {
  description = "Region of the repository. Keep it next to the cluster to avoid egress cost."
  type        = string
  default     = "asia-southeast2"
}

variable "repository_id" {
  description = "Repository ID, e.g. 'apps'. Images are pushed to <location>-docker.pkg.dev/<project>/<repository_id>/<image>."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.repository_id))
    error_message = "repository_id must be lowercase letters, digits or hyphens and start with a letter."
  }
}

variable "description" {
  description = "Human-readable description of the repository."
  type        = string
  default     = "Docker images for platform workloads"
}

variable "immutable_tags" {
  description = "Prevent a tag from being moved to a different image once pushed (recommended for prod)."
  type        = bool
  default     = false
}

variable "cleanup_policy_dry_run" {
  description = "If true, cleanup policies only log what they would delete."
  type        = bool
  default     = false
}

variable "untagged_retention_days" {
  description = "Delete untagged image versions older than this many days."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_retention_days >= 1
    error_message = "untagged_retention_days must be at least 1."
  }
}

variable "retention_days" {
  description = "Delete any image version older than this many days (unless kept by keep_recent_versions)."
  type        = number
  default     = 90

  validation {
    condition     = var.retention_days >= 1
    error_message = "retention_days must be at least 1."
  }
}

variable "keep_recent_versions" {
  description = "Always keep this many most recent versions of each image."
  type        = number
  default     = 10

  validation {
    condition     = var.keep_recent_versions >= 1
    error_message = "keep_recent_versions must be at least 1."
  }
}
