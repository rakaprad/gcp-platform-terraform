# artifact-registry

Regional **Docker** repository in Artifact Registry with cleanup policies so storage cost doesn't grow forever.

Cleanup policies:

| Policy | Action | Rule |
|--------|--------|------|
| `delete-untagged` | DELETE | untagged versions older than `untagged_retention_days` (7) |
| `delete-old` | DELETE | any version older than `retention_days` (90) |
| `keep-recent` | KEEP | the newest `keep_recent_versions` (10) of each image; KEEP beats DELETE |

Set `cleanup_policy_dry_run = true` first if you are attaching this to an existing repository.

## Usage

```hcl
module "artifact_registry" {
  source         = "../../modules/artifact-registry"
  project_id     = "my-project-id"
  repository_id  = "apps"
  immutable_tags = true
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `project_id`, `repository_id` | Project and repo ID | required |
| `location` | Region | `asia-southeast2` |
| `description` | Description | see file |
| `immutable_tags` | Disallow re-tagging | `false` |
| `cleanup_policy_dry_run` | Log only | `false` |
| `untagged_retention_days`, `retention_days`, `keep_recent_versions` | Cleanup tuning | `7`, `90`, `10` |

## Outputs

`repository_id`, `repository_name`, `location`, `repository_url`.
