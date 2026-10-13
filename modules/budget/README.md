# budget

Monthly **billing budget** scoped to one project, with alerts at 50 %, 90 % and 100 % of actual spend plus 100 % of *forecasted* spend. Budgets alert; they do **not** cap spending.

Needs a billing account ID and the `billingbudgets.googleapis.com` API, and the caller needs `roles/billing.costsManager` (or Billing Account Administrator) on the billing account. In this repo it is optional: the environments only create it when `billing_account_id` is set.

## Usage

```hcl
module "budget" {
  source             = "../../modules/budget"
  count              = var.billing_account_id == null ? 0 : 1
  billing_account_id = var.billing_account_id
  project_number     = data.google_project.this.number
  display_name       = "platform-dev"
  amount             = 100
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `billing_account_id` | Billing account | required |
| `project_number` | Numeric project number | required |
| `display_name` | Budget name | required |
| `amount` | Monthly amount | required |
| `currency_code` | Must match billing account | `USD` |
| `threshold_percents` | Actual-spend thresholds | `[0.5, 0.9, 1.0]` |
| `notification_channels` | Extra Monitoring channels | `[]` |

## Outputs

`budget_name`.
