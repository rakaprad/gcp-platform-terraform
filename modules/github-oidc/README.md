# github-oidc

Keyless GitHub Actions → GCP authentication with **Workload Identity Federation**.

Creates:

- A Workload Identity **pool** and an **OIDC provider** trusting `https://token.actions.githubusercontent.com`
- An `attribute_condition` that only accepts tokens whose `repository_owner` **and** `repository` match `github_repository`
- **Deploy SA** (`github-deploy`) for app pipelines:
  - `roles/artifactregistry.writer` on **one repository** (not project-wide)
  - `roles/container.developer` on the project (deploy workloads; cannot change cluster config or RBAC)
- **Terraform SA** (`github-terraform`) for this repo's workflow, with a list of scoped admin roles (never `owner`/`editor`, enforced by validation) (state bucket access is granted in `bootstrap/`)
- `roles/iam.workloadIdentityUser` bindings so only identities from `github_repository` can impersonate the two SAs

No service account keys are created anywhere.

## Usage

```hcl
module "github_oidc" {
  source                          = "../../modules/github-oidc"
  project_id                      = "my-project-id"
  github_repository               = "rakaprad/gcp-platform-terraform"
  artifact_registry_location      = module.artifact_registry.location
  artifact_registry_repository_id = module.artifact_registry.repository_id
}
```

In a workflow:

```yaml
permissions:
  id-token: write
steps:
  - uses: google-github-actions/auth@v3
    with:
      workload_identity_provider: ${{ vars.DEV_WIF_PROVIDER }}   # output workload_identity_provider
      service_account: ${{ vars.DEV_TF_SERVICE_ACCOUNT }}        # output terraform_service_account_email
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `project_id` | Project ID | required |
| `github_repository` | `owner/name` allowed to authenticate | required |
| `pool_id`, `provider_id` | WIF IDs | `github`, `github-oidc` |
| `deploy_service_account_id`, `terraform_service_account_id` | SA IDs | `github-deploy`, `github-terraform` |
| `artifact_registry_location`, `artifact_registry_repository_id` | Repo the deploy SA can push to | required |
| `terraform_roles` | Project roles for the Terraform SA | see `variables.tf` |

## Outputs

`workload_identity_provider`, `deploy_service_account_email`, `terraform_service_account_email`.
