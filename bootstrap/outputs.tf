output "state_bucket" {
  description = "Name of the state bucket. Put it in envs/<env>/backend.hcl."
  value       = google_storage_bucket.tfstate.name
}
