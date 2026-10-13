locals {
  env  = "prod"
  name = "platform-${local.env}"

  labels = {
    env        = local.env
    managed-by = "terraform"
    repo       = "gcp-platform-terraform"
  }

  apis = [
    "artifactregistry.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "sts.googleapis.com",
  ]
}

data "google_project" "this" {
  project_id = var.project_id
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)

  project = var.project_id
  service = each.value

  # Don't switch APIs off on destroy: other things in the project may use them.
  disable_on_destroy = false
}

module "network" {
  source = "../../modules/network"

  project_id       = var.project_id
  name             = local.name
  region           = var.region
  subnet_cidr      = "10.20.0.0/20"
  pods_cidr        = "10.24.0.0/14"
  services_cidr    = "10.28.0.0/20"
  enable_flow_logs = true

  depends_on = [google_project_service.apis]
}

module "gke" {
  source = "../../modules/gke"

  project_id                 = var.project_id
  name                       = local.name
  region                     = var.region
  network_id                 = module.network.network_id
  subnetwork_id              = module.network.subnetwork_id
  pods_range_name            = module.network.pods_range_name
  services_range_name        = module.network.services_range_name
  master_ipv4_cidr_block     = "172.16.0.16/28"
  master_authorized_networks = var.master_authorized_networks
  release_channel            = "STABLE"
  deletion_protection        = true

  depends_on = [google_project_service.apis]
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id           = var.project_id
  location             = var.region
  repository_id        = "apps"
  immutable_tags       = true
  keep_recent_versions = 20

  depends_on = [google_project_service.apis]
}

module "github_oidc" {
  source = "../../modules/github-oidc"

  project_id                      = var.project_id
  github_repository               = var.github_repository
  artifact_registry_location      = module.artifact_registry.location
  artifact_registry_repository_id = module.artifact_registry.repository_id

  depends_on = [google_project_service.apis]
}

module "budget" {
  source = "../../modules/budget"
  count  = var.billing_account_id == null ? 0 : 1

  billing_account_id = var.billing_account_id
  project_number     = data.google_project.this.number
  display_name       = local.name
  amount             = var.budget_amount
  currency_code      = var.budget_currency

  depends_on = [google_project_service.apis]
}
