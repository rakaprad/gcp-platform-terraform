output "repository_id" {
  description = "Repository ID."
  value       = google_artifact_registry_repository.this.repository_id
}

output "repository_name" {
  description = "Full resource name of the repository."
  value       = google_artifact_registry_repository.this.name
}

output "location" {
  description = "Repository location."
  value       = google_artifact_registry_repository.this.location
}

output "repository_url" {
  description = "Docker registry URL to tag and push images to."
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.this.repository_id}"
}
