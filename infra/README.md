# Terraform Infrastructure & GitHub CI/CD Guide                                                                        #*eddiere

This directory contains Terraform code to automatically provision a **$0.00/month GCP Always Free VM** (`e2-micro`), configure firewall rules, install Docker, and launch the Prometheus + Grafana monitoring stack on boot.

---

## 🔍 What Happens If Resources Have Already Been Created?

Terraform tracks all resources using a **State File (`terraform.tfstate`)**. Here is how Terraform behaves depending on your situation:

### Case 1: You re-run `terraform apply` locally (Normal Behavior)
- **What Happens**: Terraform compares your code against `terraform.tfstate` and GCP.
- **Outcome**: **No duplicates are created.** If no code changed, Terraform outputs:
  `No changes. Your infrastructure matches the configuration.`

---

### Case 2: You manually created the VM in GCP console earlier
- **What Happens**: If you try to run `terraform apply` when the VM already exists in GCP but Terraform doesn't know about it yet, GCP will return an error:
  `Error 409: Already Exists: Instance monitoring-stack-vm already exists`
- **Solution (Import existing VM into Terraform state)**:
  Run these import commands so Terraform takes management of your existing resources without recreating them:
  ```bash
  cd infra
  terraform import google_compute_instance.monitoring_vm projects/YOUR_GCP_PROJECT_ID/zones/us-central1-a/instances/monitoring-stack-vm
  terraform import google_compute_firewall.allow_grafana projects/YOUR_GCP_PROJECT_ID/global/firewalls/allow-grafana-monitoring
  terraform import google_compute_firewall.allow_prometheus projects/YOUR_GCP_PROJECT_ID/global/firewalls/allow-prometheus-monitoring
  ```

---

### Case 3: Sharing State across CI/CD & Local Machines (GCS Remote Backend)
If you want GitHub Actions CI/CD and your local computer to share the exact same Terraform state:

1. Create a free GCP Cloud Storage bucket:
   ```bash
   gcloud storage buckets create gs://YOUR_GCP_PROJECT_ID-tfstate --location=us-central1
   ```
2. Uncomment/add the backend configuration in `infra/main.tf`:
   ```hcl
   terraform {
     backend "gcs" {
       bucket = "YOUR_GCP_PROJECT_ID-tfstate"
       prefix = "monitoring-stack/state"
     }
   }
   ```

---

## 🔑 1. How to Connect your GCP Account before running Terraform locally

### Method A: Using Google Cloud SDK (Recommended & Fast)
1. Log in to your Google Account:
   ```bash
   gcloud auth login
   ```
2. Set **Application Default Credentials (ADC)** for Terraform:
   ```bash
   gcloud auth application-default login
   ```
3. Set your active GCP Project ID:
   ```bash
   gcloud config set project YOUR_GCP_PROJECT_ID
   ```

---

## 🚀 2. Running Terraform Locally

```bash
cd infra

# 1. Copy sample variables file
cp terraform.tfvars.example terraform.tfvars

# 2. Initialize, plan, and apply
terraform init
terraform plan
terraform apply -auto-approve
```

---

## 🤖 3. Automated GitHub Actions CI/CD Pipeline

Add `GCP_PROJECT_ID` and `GCP_SA_KEY` to GitHub Repository Secrets (**Settings** > **Secrets and variables** > **Actions**).
- **PRs**: Runs `terraform plan` validation.
- **Push to `main`**: Runs `terraform apply` safely.
