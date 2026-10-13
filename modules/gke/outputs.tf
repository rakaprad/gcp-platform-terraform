output "cluster_name" {
  description = "Name of the cluster."
  value       = google_container_cluster.this.name
}

output "cluster_location" {
  description = "Region of the cluster."
  value       = google_container_cluster.this.location
}

output "endpoint" {
  description = "Control plane endpoint IP."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "workload_identity_pool" {
  description = "Workload Identity pool for Kubernetes service accounts (always enabled on Autopilot)."
  value       = "${var.project_id}.svc.id.goog"
}

output "node_service_account" {
  description = "Email of the node service account."
  value       = google_service_account.nodes.email
}
