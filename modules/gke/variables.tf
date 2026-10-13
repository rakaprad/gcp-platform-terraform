variable "project_id" {
  description = "GCP project ID to create the cluster in."
  type        = string
}

variable "name" {
  description = "Cluster name. Also used for the node service account ID (<name>-nodes)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{3,22}[a-z0-9]$", var.name))
    error_message = "name must be 5-24 chars of lowercase letters, digits or hyphens (the node SA ID adds '-nodes' and is limited to 30 chars)."
  }
}

variable "region" {
  description = "Region of the Autopilot cluster."
  type        = string
  default     = "asia-southeast2"
}

variable "network_id" {
  description = "ID of the VPC the cluster attaches to."
  type        = string
}

variable "subnetwork_id" {
  description = "ID of the subnet the cluster attaches to."
  type        = string
}

variable "pods_range_name" {
  description = "Name of the subnet secondary range used for pods."
  type        = string
}

variable "services_range_name" {
  description = "Name of the subnet secondary range used for services."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "/28 range for the control plane's private endpoint. Must not overlap any VPC range."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.master_ipv4_cidr_block)) && endswith(var.master_ipv4_cidr_block, "/28")
    error_message = "master_ipv4_cidr_block must be a valid IPv4 /28 CIDR, e.g. 172.16.0.0/28."
  }
}

variable "enable_private_endpoint" {
  description = "If true, the control plane has no public endpoint at all (you then need a bastion/VPN to run kubectl)."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "CIDRs allowed to reach the Kubernetes API endpoint. Empty list = no external access."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []

  validation {
    condition     = alltrue([for n in var.master_authorized_networks : can(cidrnetmask(n.cidr_block))])
    error_message = "Every master_authorized_networks entry needs a valid IPv4 cidr_block."
  }
}

variable "release_channel" {
  description = "GKE release channel: RAPID, REGULAR or STABLE."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR or STABLE."
  }
}

variable "deletion_protection" {
  description = "Block `terraform destroy` of the cluster. Keep true for production."
  type        = bool
  default     = true
}
