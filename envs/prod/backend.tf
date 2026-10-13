# Partial configuration: the bucket is supplied at init time so no
# project-specific value is committed.
#   terraform init -backend-config=backend.hcl
terraform {
  backend "gcs" {
    prefix = "envs/prod"
  }
}
