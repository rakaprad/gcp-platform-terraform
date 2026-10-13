variable "project_id" {
  description = "GCP project ID for the prod environment."
  type        = string
}

variable "region" {
  description = "Default region for all resources."
  type        = string
  default     = "asia-southeast2"
}

variable "github_repository" {
  description = "GitHub repository ('owner/name') allowed to authenticate via Workload Identity Federation."
  type        = string
}

variable "master_authorized_networks" {
  description = "CIDRs allowed to reach the GKE API endpoint (e.g. your office or VPN egress IP)."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "billing_account_id" {
  description = "Billing account ID. Leave null to skip creating the budget."
  type        = string
  default     = null
}

variable "budget_amount" {
  description = "Monthly budget amount in budget_currency."
  type        = number
  default     = 500
}

variable "budget_currency" {
  description = "Budget currency. Must match the billing account currency."
  type        = string
  default     = "USD"
}
