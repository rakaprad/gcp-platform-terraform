resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = var.name
  auto_create_subnetworks = false # custom mode: we decide every CIDR
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "this" {
  project                  = var.project_id
  name                     = "${var.name}-${var.region}"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true # private nodes reach Google APIs without public IPs

  # VPC-native GKE: pods and services get their own alias IP ranges.
  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_cidr
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

# Cloud NAT gives private nodes outbound internet (e.g. pulling public images)
# without assigning them external IPs.
resource "google_compute_router" "this" {
  project = var.project_id
  name    = "${var.name}-router"
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  project                            = var.project_id
  name                               = "${var.name}-nat"
  region                             = var.region
  router                             = google_compute_router.this.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.this.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall basics. GCP denies all ingress by default; GKE adds the rules it
# needs for control plane -> node traffic itself.
resource "google_compute_firewall" "allow_internal" {
  project     = var.project_id
  name        = "${var.name}-allow-internal"
  network     = google_compute_network.this.id
  description = "Allow traffic between nodes and pods inside the VPC."
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [var.subnet_cidr, var.pods_cidr]

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  project     = var.project_id
  name        = "${var.name}-allow-health-checks"
  network     = google_compute_network.this.id
  description = "Allow Google Cloud load balancer health checks."
  direction   = "INGRESS"
  priority    = 1000

  # Documented Google health-check source ranges.
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  allow {
    protocol = "tcp"
  }
}
