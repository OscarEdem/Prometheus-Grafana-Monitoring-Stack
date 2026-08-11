# Prometheus & Grafana Monitoring Stack                                                                                   #*eddiere

A production-ready, ultra-lightweight infrastructure and container monitoring stack using **Prometheus**, **Grafana**, **Node Exporter**, and **cAdvisor**.

---

## ⚡ Key Highlights

- **Ultra Low Overhead**: Uses ~350 MB – 500 MB RAM total (vastly lighter than self-hosted Sentry).
- **Auto-Discovery**: `cAdvisor` automatically detects and monitors resource metrics across all running Docker containers.
- **Production-Ready**: Configured with Grafana on port `3001` to eliminate port conflicts with Next.js/React applications.
- **Terraform Automated**: Includes an `infra/` folder with complete Terraform IaC scripts to provision a **$0.00/month GCP Always Free VM (`e2-micro`)** in 1 minute.
- **Multi-Project & Cloud Support**: Capable of monitoring dozens of local containers, remote EC2/VPS instances, and GCP Cloud Run services.

---

## 🚀 Quick Start

### Option A: Spin Up Locally with Docker
```bash
docker compose up -d
```
- **Grafana UI**: [http://localhost:3001](http://localhost:3001) *(Default login: `admin` / `admin`)*
- **Prometheus UI**: [http://localhost:9090](http://localhost:9090)

### Option B: Deploy 24/7 Server on GCP ($0/mo) via Terraform
```bash
cd infra
cp terraform.tfvars.example terraform.tfvars  # Set your gcp_project_id
terraform init
terraform apply -auto-approve
```

---

## 📁 Repository Structure

```text
.
├── docker-compose.yml             # Main Docker Compose configuration
├── docker-compose.monitoring.yml  # Deployment configuration variant
├── prometheus.yml                 # Prometheus scrape configuration & jobs
├── infra/                         # Terraform Infrastructure-as-Code directory
│   ├── main.tf                    # GCP Compute Engine VM definition (e2-micro)
│   ├── firewall.tf                # GCP Firewall rules (Ports 3001, 9090)
│   ├── variables.tf               # Terraform variables configuration
│   ├── outputs.tf                 # Terraform outputs (IP, Grafana URL)
│   └── terraform.tfvars.example   # Example variables input file
└── docs/                          # Comprehensive stack documentation
    ├── README.md                  # Documentation overview
    ├── gcp-free-vm-deployment.md  # GCP Always Free VM ($0/mo) deployment guide
    ├── local-testing.md           # Local setup, testing & dashboard import guide
    ├── capacity-and-multi-project.md # Scaling & multi-project monitoring guide
    └── gcp-cloud-run-monitoring.md   # GCP Cloud Run integration guide
```

---

## 📖 Comprehensive Documentation

- 🟢 [GCP Always Free VM ($0/mo) Deployment Guide](./docs/gcp-free-vm-deployment.md) - **Best option**: Deploy 24/7 with persistent storage for $0/month on GCP `e2-micro`.
- 🛠️ [Terraform IaC Guide](./infra/README.md) - Deploy the $0/mo server automated via Terraform.
- 🧪 [Local Testing & Execution Guide](./docs/local-testing.md) - How to test locally and import pre-built Grafana dashboards.
- 📘 [Capacity & Multi-Project Guide](./docs/capacity-and-multi-project.md) - Scalability limits, container auto-discovery, and `/metrics` app scraping.
- ☁️ [GCP Cloud Run Monitoring Guide](./docs/gcp-cloud-run-monitoring.md) - Step-by-step setup for Google Cloud Monitoring & Grafana.
