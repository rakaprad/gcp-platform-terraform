terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }

  # Bootstrap uses local state on purpose: the bucket it creates is where every
  # other state file lives. Keep bootstrap/terraform.tfstate safe, or migrate it
  # into the new bucket afterwards (see README).
}

provider "google" {
  project = var.project_id
  region  = var.location
}
