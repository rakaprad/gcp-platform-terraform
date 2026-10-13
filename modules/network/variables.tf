variable "project_id" {
  description = "GCP project ID to create the network in."
  type        = string
}

variable "name" {
  description = "Name of the VPC. Also used as a prefix for the subnet, router, NAT and firewall rules."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,40}[a-z0-9])?$", var.name))
    error_message = "name must be lowercase letters, digits or hyphens, start with a letter and be at most 42 characters."
  }
}

variable "region" {
  description = "Region for the subnet, Cloud Router and Cloud NAT."
  type        = string
  default     = "asia-southeast2"
}

variable "subnet_cidr" {
  description = "Primary IPv4 range of the subnet (used by nodes)."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr))
    error_message = "subnet_cidr must be a valid IPv4 CIDR, e.g. 10.10.0.0/20."
  }
}

variable "pods_cidr" {
  description = "Secondary IPv4 range for GKE pods."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.pods_cidr))
    error_message = "pods_cidr must be a valid IPv4 CIDR."
  }
}

variable "services_cidr" {
  description = "Secondary IPv4 range for GKE services."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.services_cidr))
    error_message = "services_cidr must be a valid IPv4 CIDR."
  }
}

variable "pods_range_name" {
  description = "Name of the secondary range for pods."
  type        = string
  default     = "pods"
}

variable "services_range_name" {
  description = "Name of the secondary range for services."
  type        = string
  default     = "services"
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs on the subnet (useful for audits, but adds logging cost)."
  type        = bool
  default     = false
}
