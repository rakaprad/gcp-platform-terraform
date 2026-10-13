output "network_id" {
  description = "ID of the VPC."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Name of the VPC."
  value       = google_compute_network.this.name
}

output "subnetwork_id" {
  description = "ID of the subnet."
  value       = google_compute_subnetwork.this.id
}

output "pods_range_name" {
  description = "Name of the secondary range for pods (pass to the gke module)."
  value       = var.pods_range_name
}

output "services_range_name" {
  description = "Name of the secondary range for services (pass to the gke module)."
  value       = var.services_range_name
}
