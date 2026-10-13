variable "project_id" {
  description = "GCP project ID that hosts the pool and service accounts."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to authenticate, as 'owner/name' (e.g. rakaprad/gcp-platform-terraform)."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$", var.github_repository))
    error_message = "github_repository must look like 'owner/name'."
  }
}

variable "pool_id" {
  description = "Workload Identity Pool ID. Deleted pools are soft-deleted for 30 days, so use a new ID if you recreate quickly."
  type        = string
  default     = "github"

  validation {
    condition     = can(regex("^[a-z0-9-]{4,32}$", var.pool_id)) && !startswith(var.pool_id, "gcp-")
    error_message = "pool_id must be 4-32 lowercase letters, digits or hyphens and must not start with 'gcp-'."
  }
}

variable "provider_id" {
  description = "Workload Identity Pool Provider ID."
  type        = string
  default     = "github-oidc"

  validation {
    condition     = can(regex("^[a-z0-9-]{4,32}$", var.provider_id)) && !startswith(var.provider_id, "gcp-")
    error_message = "provider_id must be 4-32 lowercase letters, digits or hyphens and must not start with 'gcp-'."
  }
}

variable "deploy_service_account_id" {
  description = "Account ID of the deploy service account used by application pipelines."
  type        = string
  default     = "github-deploy"
}

variable "artifact_registry_location" {
  description = "Location of the Artifact Registry repository the deploy SA may push to."
  type        = string
}

variable "artifact_registry_repository_id" {
  description = "ID of the Artifact Registry repository the deploy SA may push to."
  type        = string
}

variable "terraform_service_account_id" {
  description = "Account ID of the service account used by the Terraform GitHub workflow."
  type        = string
  default     = "github-terraform"
}

variable "terraform_roles" {
  description = "Project roles for the Terraform SA: just enough to manage the resources in this repo."
  type        = list(string)
  default = [
    "roles/artifactregistry.admin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/container.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
  ]

  validation {
    condition     = !contains(var.terraform_roles, "roles/owner") && !contains(var.terraform_roles, "roles/editor")
    error_message = "Do not grant basic roles (owner/editor) to the CI service account."
  }
}
