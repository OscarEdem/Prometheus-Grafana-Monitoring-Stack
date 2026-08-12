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

# Reserve a static external IP address for the monitoring VM
resource "google_compute_address" "static_ip" {
  name         = "monitoring-vm-static-ip"
  region       = var.gcp_region
  depends_on   = [google_project_service.compute_api]
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

    # Allocate the reserved static external IP address
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  # Automated startup script to install Docker & launch monitoring stack on boot
  metadata_startup_script = <<-EOF
    #!/bin/bash
    exec > >(tee -a /var/log/monitoring-startup.log) 2>&1
    echo "[INFO] Starting Automated Monitoring Stack Deployment at $(date)..."

    # Wait for cloud-init dpkg locks to release on initial boot
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
      echo "[INFO] Waiting for Ubuntu background package locks to release..."
      sleep 3
    done

    # 1. Enable 2GB Swap File to expand 1GB RAM to 3GB Virtual Memory
    if [ ! -f /swapfile ]; then
      echo "[INFO] Creating 2GB Swap file for RAM optimization..."
      fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi

    # 2. Update & install standard Ubuntu packages
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2 git

    # 3. Start & enable Docker service
    systemctl daemon-reload
    systemctl enable --now docker

    # 4. Create app directory
    mkdir -p /opt/monitoring
    cd /opt/monitoring

    # 5. Clone Monitoring Stack Repository
    if [ ! -d "/opt/monitoring/.git" ]; then
      git clone ${var.repository_url} .
    else
      git pull origin main
    fi

    # 6. Fetch VM Public IP and update/write to .env for Grafana root URL
    VM_PUBLIC_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
    if [ -f .env ]; then
      sed -i '/^VM_PUBLIC_IP=/d' .env
      echo "VM_PUBLIC_IP=$VM_PUBLIC_IP" >> .env
    else
      echo "VM_PUBLIC_IP=$VM_PUBLIC_IP" > .env
    fi

    # 7. Clean stale containers & spin up fresh Docker containers
    docker compose down --remove-orphans || true
    docker compose up -d

    echo "[SUCCESS] Prometheus & Grafana Monitoring Stack is up and running at $(date)!"
  EOF

  lifecycle {
    ignore_changes = [metadata_startup_script]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  depends_on = [google_project_service.compute_api]
}
