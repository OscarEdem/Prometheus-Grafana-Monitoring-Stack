# Terraform Infrastructure Provisioning ($0/mo GCP Always Free VM)                                                     #*eddiere

This directory contains Terraform code to automatically provision a **$0.00/month GCP Always Free VM** (`e2-micro`), configure firewall rules, install Docker, and launch the Prometheus + Grafana monitoring stack on boot.

---

## 📋 Prerequisites

1. **Terraform CLI** installed locally (`>= 1.0.0`).
2. **Google Cloud SDK (`gcloud`)** installed and authenticated:
   ```bash
   gcloud auth application-default login
   ```
3. An active **GCP Project**.

---

## 🚀 Quick Start Guide

### 1. Navigate to the `infra/` directory:
```bash
cd infra
```

### 2. Create your `terraform.tfvars` file:
Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```
Edit `terraform.tfvars` and set your GCP Project ID:
```hcl
gcp_project_id = "your-actual-gcp-project-id"
```

### 3. Initialize & Deploy with Terraform:
```bash
# Initialize Terraform provider plugins
terraform init

# Review execution plan
terraform plan

# Provision infrastructure
terraform apply -auto-approve
```

---

## 📊 Outputs & Verification

Once `terraform apply` finishes, Terraform will output your server's public IP and dashboard URLs:

```text
Outputs:

grafana_url = "http://34.123.45.67:3001"
prometheus_url = "http://34.123.45.67:9090"
vm_name = "monitoring-stack-vm"
vm_public_ip = "34.123.45.67"
```

Wait ~1 to 2 minutes for the VM startup script to finish installing Docker and cloning the repository.
Then open Grafana at `http://YOUR_PUBLIC_IP:3001`!

---

## 🧹 Destroying Resources

If you ever want to tear down the server and firewall rules:
```bash
terraform destroy -auto-approve
```
