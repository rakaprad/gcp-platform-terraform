resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "tfstate" {
  #checkov:skip=CKV_GCP_62:Usage logs bucket not needed; enable Cloud Audit Logs data access for GCS instead

  project  = var.project_id
  name     = var.bucket_name
  location = var.location

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true       # IAM only, no per-object ACLs
  public_access_prevention    = "enforced" # can never be made public
  force_destroy               = false

  # Every state write creates a new object version, so a bad apply or a
  # corrupted state can be rolled back.
  versioning {
    enabled = true
  }

  # Keep old state versions for a while, but not forever.
  lifecycle_rule {
    condition {
      num_newer_versions         = 10
      days_since_noncurrent_time = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    managed-by = "terraform"
    purpose    = "terraform-state"
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.storage]
}

# CI service accounts get read/write on *their own* state prefix only, so the
# dev pipeline cannot read or modify prod state. Bucket-level requests (object
# listing during `terraform init`) are allowed so the GCS backend still works.
resource "google_storage_bucket_iam_member" "state_writers" {
  for_each = var.state_writers

  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = each.value

  condition {
    title       = "state-${replace(each.key, "/", "-")}"
    description = "Only objects under ${each.key}/"
    expression  = "resource.type == \"storage.googleapis.com/Bucket\" || resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tfstate.name}/objects/${each.key}/\")"
  }
}
