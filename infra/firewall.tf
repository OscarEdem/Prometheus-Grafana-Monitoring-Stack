# --------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                #*eddiere
# Firewall rule for Grafana UI (Port 3001)
resource "google_compute_firewall" "allow_grafana" {
  name    = "allow-grafana-monitoring"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3001"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring-stack"]
  description   = "Allow inbound HTTP access to Grafana UI on port 3001"
}

# Firewall rule for Prometheus Metrics UI (Port 9090)
resource "google_compute_firewall" "allow_prometheus" {
  name    = "allow-prometheus-monitoring"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring-stack"]
  description   = "Allow inbound HTTP access to Prometheus UI on port 9090"
}
