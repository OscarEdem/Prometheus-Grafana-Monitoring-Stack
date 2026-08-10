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
├── docker-compose.monitoring.yml  # Duplicate setup for specific deployment scripts
├── prometheus.yml                 # Prometheus scrape configuration & jobs
└── docs/                          # Stack documentation
    ├── README.md                  # Stack overview & quickstart
    ├── capacity-and-multi-project.md # Scaling & multi-project monitoring guide
    └── gcp-cloud-run-monitoring.md   # GCP Cloud Run integration guide
```

---

## 🚀 Quick Start

### 1. Start the Stack
Run the following command in the `monitoring/` directory:
```bash
docker compose up -d
```

### 2. Verify Services
Check running containers:
```bash
docker compose ps
```

Access the dashboards:
- **Grafana UI**: [http://localhost:3001](http://localhost:3001) (Default credentials: `admin` / `admin`)
- **Prometheus Targets**: [http://localhost:9090/targets](http://localhost:9090/targets)
- **Node Exporter Metrics**: [http://localhost:9100/metrics](http://localhost:9100/metrics)
- **cAdvisor Metrics**: [http://localhost:8080/metrics](http://localhost:8080/metrics)

### 3. Connect Prometheus Data Source in Grafana
1. Open Grafana at `http://localhost:3001`.
2. Navigate to **Connections** > **Data Sources** > **Add Data Source**.
3. Select **Prometheus**.
4. Set URL to `http://prometheus:9090` (internal Docker network name).
5. Click **Save & Test**.

---

## 📖 Documentation Index

- 📘 [Capacity & Multi-Project Monitoring Guide](./capacity-and-multi-project.md) - Learn how many projects/containers can be monitored and how to filter them.
- ☁️ [GCP Cloud Run Monitoring Guide](./gcp-cloud-run-monitoring.md) - Learn how to integrate GCP Cloud Run serverless services with Grafana.
