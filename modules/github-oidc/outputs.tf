output "workload_identity_provider" {
  description = "Full provider resource name, used as `workload_identity_provider` in google-github-actions/auth."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "deploy_service_account_email" {
  description = "Service account for application build/deploy pipelines."
  value       = google_service_account.deploy.email
}

output "terraform_service_account_email" {
  description = "Service account for the Terraform workflow."
  value       = google_service_account.terraform.email
}
