output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.cluster_name
}

output "get_credentials_command" {
  description = "Command to configure kubectl for this cluster."
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${module.gke.cluster_location} --project ${var.project_id}"
}

output "artifact_registry_url" {
  description = "Where to push Docker images."
  value       = module.artifact_registry.repository_url
}

output "workload_identity_provider" {
  description = "Value for google-github-actions/auth `workload_identity_provider`."
  value       = module.github_oidc.workload_identity_provider
}

output "deploy_service_account_email" {
  description = "Service account for app build/deploy pipelines."
  value       = module.github_oidc.deploy_service_account_email
}

output "terraform_service_account_email" {
  description = "Service account for the Terraform workflow."
  value       = module.github_oidc.terraform_service_account_email
}
