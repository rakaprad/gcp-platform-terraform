variable "billing_account_id" {
  description = "Billing account ID (XXXXXX-XXXXXX-XXXXXX)."
  type        = string

  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must look like 012345-6789AB-CDEF01."
  }
}

variable "project_number" {
  description = "Numeric project number the budget is scoped to."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.project_number))
    error_message = "project_number must be numeric (not the project ID)."
  }
}

variable "display_name" {
  description = "Budget name shown in the Billing console."
  type        = string
}

variable "amount" {
  description = "Monthly budget amount in currency_code units."
  type        = number

  validation {
    condition     = var.amount > 0
    error_message = "amount must be greater than 0."
  }
}

variable "currency_code" {
  description = "Currency of the amount. Must match the billing account's currency (e.g. USD or IDR)."
  type        = string
  default     = "USD"
}

variable "threshold_percents" {
  description = "Actual-spend thresholds (fractions of amount) that trigger alerts."
  type        = list(number)
  default     = [0.5, 0.9, 1.0]

  validation {
    condition     = alltrue([for t in var.threshold_percents : t > 0])
    error_message = "threshold_percents must be positive fractions, e.g. 0.5 for 50%."
  }
}

variable "notification_channels" {
  description = "Optional Cloud Monitoring notification channel IDs to notify in addition to billing admins."
  type        = list(string)
  default     = []
}
