# GCP Always Free VM Deployment Guide ($0/month)                                                                       #*eddiere

This guide explains how to host your entire Prometheus + Grafana monitoring stack on Google Cloud Platform (GCP) for **$0.00 / month forever** using GCP's **Always Free Tier**.

---

## ⚡ Why GCP Always Free VM is Superior to Cloud Hosting Sandboxes

| Feature | GCP `e2-micro` VM (Always Free) | Render Free Tier |
| :--- | :--- | :--- |
| **Monthly Cost** | **`$0.00 / month`** | `$0.00 / month` |
| **RAM Allocation** | **1.0 GB RAM** | 512 MB RAM |
| **Disk Storage** | **30 GB Persistent Disk ($0)** | Ephemeral (Resets on restart) |
| **24/7 Continuous Uptime** | ✅ Never Sleeps | ⚠️ Sleeps after 15 mins inactivity |
| **Docker Compose Support** | ✅ Full Native `docker compose` | ❌ No `docker compose` support |
| **Hardware Exporters** | ✅ Full `node_exporter` + `cAdvisor` | ❌ No root/host access |

---

## 🚀 Recommended: Automated Deployment via Terraform

The repository includes a ready-to-use [`infra/`](../infra/) folder containing complete Infrastructure-as-Code (IaC) Terraform scripts to automatically provision the GCP instance, firewall rules, and startup script.

```bash
# 1. Navigate to the terraform directory
cd infra

# 2. Copy and update your GCP Project ID in terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# 3. Provision the $0/mo server in 1 minute!
terraform init
terraform apply -auto-approve
```

---

## 📋 Manual Deployment Alternative (GCP Always Free Instance)

If you prefer to create the instance manually without Terraform:

- **Machine Type**: `e2-micro` (2 vCPU, 1 GB RAM).
- **Allowed Regions**: `us-central1` (Iowa), `us-west1` (Oregon), `us-east1` (South Carolina).
- **Boot Disk**: Up to **30 GB Standard Persistent Disk**.

### Manual Command Line (`gcloud` CLI):
```bash
# Create Instance
gcloud compute instances create monitoring-stack \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-standard \
    --tags=http-server,https-server

# Open Firewall Port 3001 (Grafana)
gcloud compute firewall-rules create allow-grafana \
    --allow=tcp:3001 \
    --target-tags=http-server

# SSH and Run Stack
gcloud compute ssh monitoring-stack
sudo apt update && sudo apt install -y docker.io docker-compose-v2 git
sudo usermod -aG docker $USER && newgrp docker
git clone https://github.com/OscarEdem/Prometheus-Grafana-Monitoring-Stack.git
cd Prometheus-Grafana-Monitoring-Stack
docker compose up -d
```
