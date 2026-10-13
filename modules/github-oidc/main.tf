locals {
  github_owner = split("/", var.github_repository)[0]

  # Any identity from the pool whose token says it came from this repository.
  repo_principal = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}

# ---------------------------------------------------------------------------
# Workload Identity Federation: GCP trusts GitHub's OIDC tokens
# ---------------------------------------------------------------------------
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions"
  description               = "Federated identities from GitHub Actions OIDC tokens"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  #checkov:skip=CKV_GCP_125:Check only recognises assertion.sub; we pin repository_owner AND repository, as Google recommends

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
  }

  # Hard gate: tokens from any other owner/repo are rejected before IAM is
  # even evaluated. Without a condition, *any* GitHub repo could use this pool.
  attribute_condition = "assertion.repository_owner == '${local.github_owner}' && assertion.repository == '${var.github_repository}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ---------------------------------------------------------------------------
# Deploy SA: what application pipelines use (push images, deploy to GKE)
# ---------------------------------------------------------------------------
resource "google_service_account" "deploy" {
  project      = var.project_id
  account_id   = var.deploy_service_account_id
  display_name = "GitHub Actions deploy"
}

resource "google_service_account_iam_member" "deploy_wif" {
  service_account_id = google_service_account.deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.repo_principal
}

# Push access to one repository only, not every repository in the project.
resource "google_artifact_registry_repository_iam_member" "deploy_writer" {
  project    = var.project_id
  location   = var.artifact_registry_location
  repository = var.artifact_registry_repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.deploy.email}"
}

# Deploy workloads (Deployments, Services, ...) but not change cluster config or RBAC.
resource "google_project_iam_member" "deploy_container_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.deploy.email}"
}

# ---------------------------------------------------------------------------
# Terraform SA: what the Terraform workflow in this repo uses
# ---------------------------------------------------------------------------
resource "google_service_account" "terraform" {
  project      = var.project_id
  account_id   = var.terraform_service_account_id
  display_name = "GitHub Actions Terraform"
}

resource "google_service_account_iam_member" "terraform_wif" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.repo_principal
}

resource "google_project_iam_member" "terraform" {
  # The Terraform SA must create service accounts and attach the GKE node SA
  # to the cluster, so it needs these roles. Its blast radius is limited by
  # the WIF condition (one repo) and GitHub environment protection rules.
  #checkov:skip=CKV_GCP_41:Required to attach the node service account to the GKE cluster
  #checkov:skip=CKV_GCP_49:Required to create the node and deploy service accounts

  for_each = toset(var.terraform_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# Access to the state bucket is granted in bootstrap/ (the layer that owns the
# bucket), so this SA never needs permission to change bucket IAM.
