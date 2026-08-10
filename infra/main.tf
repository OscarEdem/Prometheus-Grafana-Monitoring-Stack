# --------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                #*eddiere
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Automatically enable Compute Engine API if disabled
resource "google_project_service" "compute_api" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# GCP Always Free Tier Compute Instance (e2-micro, 1GB RAM, 30GB Disk)
resource "google_compute_instance" "monitoring_vm" {
  name         = "monitoring-stack-vm"
  machine_type = "e2-micro" # Qualifies for GCP Always Free Tier ($0/mo)
  zone         = var.gcp_zone

  tags = ["monitoring-stack", "http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30 # 30 GB Standard Persistent Disk (Always Free Tier)
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"

    # Allocate a public external IP address
    access_config {
      // Ephemeral public IP
    }
  }

  # Automated startup script to install Docker & launch monitoring stack on boot
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # Log output to startup script log file
    exec > >(tee /var/log/monitoring-startup.log) 2>&1
    echo "[INFO] Starting Automated Monitoring Stack Deployment..."

    # Install Docker, Docker Compose plugin, and Git
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2 git

    # Enable and start Docker service
    systemctl enable --now docker

    # Prepare deployment directory
    mkdir -p /opt/monitoring
    cd /opt/monitoring

    # Clone Monitoring Stack Repository
    if [ ! -d "/opt/monitoring/.git" ]; then
      git clone ${var.repository_url} .
    else
      git pull origin main
    fi

    # Launch Monitoring Stack via Docker Compose
    docker compose up -d

    echo "[SUCCESS] Prometheus & Grafana Monitoring Stack is up and running!"
  EOF

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  depends_on = [google_project_service.compute_api]
}
