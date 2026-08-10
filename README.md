# Prometheus & Grafana Monitoring Stack                                                                                   #*eddiere

A production-ready, ultra-lightweight infrastructure and container monitoring stack using **Prometheus**, **Grafana**, **Node Exporter**, and **cAdvisor**.

---

## ⚡ Key Highlights

- **Ultra Low Overhead**: Uses ~350 MB – 500 MB RAM total (vastly lighter than self-hosted Sentry).
- **Auto-Discovery**: `cAdvisor` automatically detects and monitors resource metrics across all running Docker containers.
- **Production-Ready**: Configured with Grafana on port `3001` to eliminate port conflicts with Next.js/React applications.
- **Multi-Project & Cloud Support**: Capable of monitoring dozens of local containers, remote EC2/VPS instances, and GCP Cloud Run services.
- **100% Free Hosting Ready**: Deployable on **GCP Always Free VM (`e2-micro`)** for 24/7 continuous uptime and persistent data at **$0.00 / month forever**.

---

## 🚀 Quick Start

### 1. Spin Up the Stack Locally
```bash
docker compose up -d
```

### 2. Access Dashboards
- **Grafana UI**: [http://localhost:3001](http://localhost:3001) *(Default login: `admin` / `admin`)*
- **Prometheus UI**: [http://localhost:9090](http://localhost:9090)
- **Node Exporter Metrics**: [http://localhost:9100/metrics](http://localhost:9100/metrics)
- **cAdvisor Metrics**: [http://localhost:8080/metrics](http://localhost:8080/metrics)

---

## 📁 Repository Structure

```text
.
├── docker-compose.yml             # Main Docker Compose configuration
├── docker-compose.monitoring.yml  # Duplicate setup for specific deployment environments
├── prometheus.yml                 # Prometheus scrape configuration & jobs
├── render.yaml                    # Render Cloud Blueprint specification ($0 free plan)
└── docs/                          # Comprehensive stack documentation
    ├── README.md                  # Documentation overview
    ├── gcp-free-vm-deployment.md  # GCP Always Free VM ($0/mo) deployment guide
    ├── local-testing.md           # Local setup, testing & dashboard import guide
    ├── capacity-and-multi-project.md # Scaling & multi-project monitoring guide
    ├── gcp-cloud-run-monitoring.md   # GCP Cloud Run integration guide
    └── render-deployment.md       # Render cloud hosting & sandbox limitations guide
```

---

## 📖 Comprehensive Documentation

- 🟢 [GCP Always Free VM ($0/mo) Deployment Guide](./docs/gcp-free-vm-deployment.md) - **Best option**: Deploy 24/7 with persistent storage for $0/month on GCP `e2-micro`.
- 🧪 [Local Testing & Execution Guide](./docs/local-testing.md) - How to test locally and import pre-built Grafana dashboards.
- 📘 [Capacity & Multi-Project Guide](./docs/capacity-and-multi-project.md) - Scalability limits, container auto-discovery, and `/metrics` app scraping.
- ☁️ [GCP Cloud Run Monitoring Guide](./docs/gcp-cloud-run-monitoring.md) - Step-by-step setup for Google Cloud Monitoring & Grafana.
- 🚀 [Render Cloud Deployment Guide](./docs/render-deployment.md) - Hosting Prometheus & Grafana on Render vs container limitations.
