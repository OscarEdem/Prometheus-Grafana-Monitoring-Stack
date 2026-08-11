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

  depends_on = [google_project_service.compute_api]
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

  depends_on = [google_project_service.compute_api]
}

# Firewall rule for Loki Log Ingestion (Port 3100) — Locked to AfroVogue AWS server only                                                                                                          #*eddiere
resource "google_compute_firewall" "allow_loki_push" {
  name    = "allow-loki-push-monitoring"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3100"]
  }

  source_ranges = ["16.192.111.188/32"]
  target_tags   = ["monitoring-stack"]
  description   = "Allow Promtail log push from AfroVogue AWS server to Loki on port 3100"

  depends_on = [google_project_service.compute_api]
}

# Firewall rule for SSH Access (Port 22)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-monitoring"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring-stack"]
  description   = "Allow inbound SSH access on port 22"

  depends_on = [google_project_service.compute_api]
}
