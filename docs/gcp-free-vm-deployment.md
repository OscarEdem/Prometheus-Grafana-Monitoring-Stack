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
| **Host Metric Monitoring** | ✅ Full `node_exporter` + `cAdvisor` | ❌ No root/host access |

---

## 📋 GCP Always Free Instance Requirements

To qualify for Google Cloud's **$0.00/month Always Free Tier**, your Compute Engine VM must match these exact settings:

- **Machine Type**: `e2-micro` (2 vCPU, 1 GB RAM).
- **Allowed Regions**:
  - `us-west1` (Oregon)
  - `us-central1` (Iowa)
  - `us-east1` (South Carolina)
- **Boot Disk**: Up to **30 GB Standard Persistent Disk** per month.
- **Egress Bandwidth**: 1 GB free outbound data per month (to non-China/Australia destinations).

---

## 🚀 Step-by-Step Deployment Guide

### Step 1: Create the GCP Always Free Instance

#### Option A: Via Google Cloud Console (GUI)
1. Open [Google Cloud Console](https://console.cloud.google.com) > **Compute Engine** > **VM Instances**.
2. Click **Create Instance**.
3. Configure the VM:
   - **Name**: `monitoring-stack`
   - **Region**: Choose `us-central1` (Iowa), `us-west1` (Oregon), or `us-east1` (South Carolina).
   - **Machine Series**: Select **E2**.
   - **Machine Type**: Select **`e2-micro` (2 vCPU, 1 GB memory)**.
4. **Boot Disk**:
   - Click **Change**.
   - Select OS: **Ubuntu 22.04 LTS** (or Debian 12).
   - Disk Type: **Standard Persistent Disk**.
   - Size: **`30 GB`**.
   - Click **Select**.
5. **Firewall**:
   - Check **Allow HTTP traffic** and **Allow HTTPS traffic**.
6. Click **Create**.

#### Option B: Via `gcloud` CLI (Command Line)
```bash
gcloud compute instances create monitoring-stack \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-standard \
    --tags=http-server,https-server,monitoring-port
```

---

### Step 2: Open Grafana Port (3001) in GCP Firewall

By default, GCP blocks incoming traffic on non-standard ports like `3001`. Create a firewall rule:

```bash
gcloud compute firewall-rules create allow-grafana \
    --allow=tcp:3001 \
    --target-tags=http-server \
    --description="Allow incoming traffic to Grafana UI"
```

---

### Step 3: Install Docker & Spin Up Monitoring Stack

1. SSH into your GCP VM instance (click **SSH** button in Cloud Console or run `gcloud compute ssh monitoring-stack`).
2. Run the setup script:

```bash
# 1. Update system packages
sudo apt update && sudo apt upgrade -y

# 2. Install Docker & Docker Compose plugin
sudo apt install -y docker.io docker-compose-v2 git

# 3. Add current user to Docker group
sudo usermod -aG docker $USER
newgrp docker

# 4. Clone your monitoring repository
git clone https://github.com/OscarEdem/Prometheus-Grafana-Monitoring-Stack.git
cd Prometheus-Grafana-Monitoring-Stack

# 5. Start the full stack in background mode
docker compose up -d
```

---

### Step 4: Verify Deployment & Access Dashboards

Run `docker compose ps` on the VM to verify all containers (`local_prometheus`, `local_grafana`, `local_node_exporter`, `local_cadvisor`) are active.

Access your monitoring dashboards:
- **Grafana Dashboard**: `http://YOUR_GCP_VM_EXTERNAL_IP:3001` *(Default login: `admin` / `admin`)*
- **Prometheus Metrics**: `http://YOUR_GCP_VM_EXTERNAL_IP:9090`

---

## 🎯 Summary

By deploying on GCP's **`e2-micro` Always Free VM**, you get:
- **$0.00 / month cost forever**.
- **100% persistent data storage** (30 GB hard drive).
- **24/7 continuous uptime** without sleeping.
- Full container and hardware health monitoring for your entire infrastructure!
