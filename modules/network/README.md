# network

Custom-mode VPC ready for a private, VPC-native GKE cluster.

Creates:

- `google_compute_network` in custom mode (no auto subnets)
- One regional subnet with **Private Google Access** and two secondary ranges (`pods`, `services`); optional VPC flow logs
- Cloud Router + **Cloud NAT** so private nodes get outbound internet without external IPs (NAT logs errors only)
- Firewall rules: allow internal traffic (nodes + pods) and Google load balancer health checks. Everything else inbound stays denied by GCP's implied deny rule.

## Usage

```hcl
module "network" {
  source        = "../../modules/network"
  project_id    = "my-project-id"
  name          = "platform-dev"
  region        = "asia-southeast2"
  subnet_cidr   = "10.10.0.0/20"
  pods_cidr     = "10.20.0.0/16"
  services_cidr = "10.30.0.0/20"
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `project_id` | GCP project ID | required |
| `name` | VPC name and prefix for related resources | required |
| `region` | Region | `asia-southeast2` |
| `subnet_cidr` / `pods_cidr` / `services_cidr` | IPv4 ranges | required |
| `pods_range_name` / `services_range_name` | Secondary range names | `pods` / `services` |
| `enable_flow_logs` | Turn on VPC flow logs | `false` |

## Outputs

`network_id`, `network_name`, `subnetwork_id`, `pods_range_name`, `services_range_name`.
