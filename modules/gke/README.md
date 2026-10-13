# gke

Private **GKE Autopilot** cluster.

- **Private nodes** (internal IPs only, outbound via Cloud NAT from the `network` module)
- Control plane access limited by **master authorized networks** (`gcp_public_cidrs_access_enabled = false`, so "any Google Cloud IP" is not trusted); optionally no public endpoint at all
- **Workload Identity**: always on in Autopilot; pods use Kubernetes service accounts mapped to IAM via the `<project>.svc.id.goog` pool, so no exported keys
- Dedicated **node service account** with `roles/container.defaultNodeServiceAccount` + `roles/artifactregistry.reader` instead of the Compute Engine default SA
- **Release channel** and weekend maintenance window
- **Deletion protection** controlled by a variable (on by default)

## Usage

```hcl
module "gke" {
  source                 = "../../modules/gke"
  project_id             = "my-project-id"
  name                   = "platform-dev"
  network_id             = module.network.network_id
  subnetwork_id          = module.network.subnetwork_id
  pods_range_name        = module.network.pods_range_name
  services_range_name    = module.network.services_range_name
  master_ipv4_cidr_block = "172.16.0.0/28"
  master_authorized_networks = [
    { cidr_block = "203.0.113.10/32", display_name = "my-laptop" },
  ]
  deletion_protection = false
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `project_id`, `name` | Project and cluster name | required |
| `region` | Region | `asia-southeast2` |
| `network_id`, `subnetwork_id`, `pods_range_name`, `services_range_name` | From the `network` module | required |
| `master_ipv4_cidr_block` | /28 for the control plane | required |
| `enable_private_endpoint` | Remove the public endpoint | `false` |
| `master_authorized_networks` | CIDRs allowed to call the API | `[]` |
| `release_channel` | `RAPID` / `REGULAR` / `STABLE` | `REGULAR` |
| `deletion_protection` | Protect against destroy | `true` |

## Outputs

`cluster_name`, `cluster_location`, `endpoint` (sensitive), `workload_identity_pool`, `node_service_account`.
