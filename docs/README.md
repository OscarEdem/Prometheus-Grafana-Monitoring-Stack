# Prometheus & Grafana Monitoring Stack Documentation                                                                   #*eddiere

Welcome to the documentation for the **Prometheus + Grafana Infrastructure & Container Monitoring Stack**.

---

## 📌 Architecture Overview

This stack provides real-time, low-overhead monitoring for server hardware health (CPU, RAM, Disk, Network) and Docker containers.

| Component | Port | Description |
| :--- | :--- | :--- |
| **Prometheus** | `9090` | Scrapes, stores, and evaluates time-series metrics every 15 seconds. |
| **Grafana** | `3001` | Visual dashboard UI for real-time charts, alerts, and metrics analysis. |
| **node_exporter** | `9100` | Exposes host machine hardware & OS metrics (CPU, RAM, disk I/O, network). |
| **cAdvisor** | `8080` | Collects resource usage and performance metrics from running Docker containers. |

---

## 📁 Directory Structure

```text
monitoring/
├── docker-compose.yml             # Main Docker Compose configuration
├── docker-compose.monitoring.yml  # Deployment configuration variant
├── prometheus.yml                 # Prometheus scrape configuration & jobs
└── docs/                          # Stack documentation
    ├── README.md                  # Stack overview
    ├── local-testing.md           # Local setup, testing & dashboard import guide
    ├── capacity-and-multi-project.md # Scaling & multi-project monitoring guide
    ├── gcp-free-vm-deployment.md  # GCP Always Free VM ($0/mo) deployment guide
    └── gcp-cloud-run-monitoring.md   # GCP Cloud Run integration guide
```

---

## 📖 Documentation Index

- 🟢 [GCP Always Free VM ($0/mo) Deployment Guide](./gcp-free-vm-deployment.md) - **Best option**: Deploy 24/7 with persistent storage for $0/month on GCP `e2-micro`.
- 🧪 [Local Testing & Execution Guide](./local-testing.md) - How to test locally and import pre-built Grafana dashboards (`1860` & `14282`).
- 📘 [Capacity & Multi-Project Monitoring Guide](./capacity-and-multi-project.md) - Learn how many projects/containers can be monitored and how to filter them.
- ☁️ [GCP Cloud Run Monitoring Guide](./gcp-cloud-run-monitoring.md) - Learn how to integrate GCP Cloud Run serverless services with Grafana via GCP Service Accounts.
