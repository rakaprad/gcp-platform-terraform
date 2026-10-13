# Dedicated node service account instead of the Compute Engine default SA,
# which has the broad Editor role in many projects.
resource "google_service_account" "nodes" {
  project      = var.project_id
  account_id   = "${var.name}-nodes"
  display_name = "GKE nodes for ${var.name}"
}

resource "google_project_iam_member" "nodes" {
  for_each = toset([
    "roles/container.defaultNodeServiceAccount", # logging, monitoring, metadata
    "roles/artifactregistry.reader",             # pull images from Artifact Registry
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_container_cluster" "this" {
  # Checkov skips: these are enforced by Autopilot itself or handled elsewhere.
  #checkov:skip=CKV_GCP_12:Autopilot always runs GKE Dataplane V2, which enforces NetworkPolicy
  #checkov:skip=CKV_GCP_13:Client certificate issuance is disabled by default on new GKE clusters
  #checkov:skip=CKV_GCP_21:Labels come from provider default_labels, which Checkov cannot see
  #checkov:skip=CKV_GCP_61:Intranode visibility is out of scope; subnet flow logs are enabled in prod
  #checkov:skip=CKV_GCP_65:Google Groups for RBAC needs a Workspace/Cloud Identity domain (roadmap)
  #checkov:skip=CKV_GCP_66:Binary Authorization is on the roadmap
  #checkov:skip=CKV_GCP_69:Autopilot always enables the GKE metadata server (Workload Identity)

  project  = var.project_id
  name     = var.name
  location = var.region # Autopilot clusters are always regional

  # Autopilot: Google manages nodes, scaling, upgrades and hardening
  # (Shielded nodes, Workload Identity, COS, etc. are always on).
  enable_autopilot    = true
  deletion_protection = var.deletion_protection

  network    = var.network_id
  subnetwork = var.subnetwork_id

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true # nodes get internal IPs only
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Only these CIDRs may reach the Kubernetes API endpoint.
  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = false

    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.nodes.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  # Weekend maintenance window (times are UTC; 17:00 UTC = 00:00 WIB).
  maintenance_policy {
    recurring_window {
      start_time = "2026-01-03T17:00:00Z"
      end_time   = "2026-01-03T23:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  depends_on = [google_project_iam_member.nodes]
}
