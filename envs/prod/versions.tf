terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  # Bill API calls (e.g. the Budgets API) to this project instead of the
  # caller's ADC quota project.
  user_project_override = true
  billing_project       = var.project_id

  # Applied to every resource that supports labels.
  default_labels = local.labels
}
