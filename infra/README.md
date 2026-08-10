# Terraform Infrastructure & GitHub CI/CD Guide                                                                        #*eddiere

This directory contains Terraform code to automatically provision a **$0.00/month GCP Always Free VM** (`e2-micro`), configure firewall rules, install Docker, and launch the Prometheus + Grafana monitoring stack on boot.

---

## 🔑 1. How to Connect your GCP Account before running Terraform locally

Choose one of the two authentication methods below:

### Method A: Using Google Cloud SDK (Recommended & Fast)
1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).
2. Log in to your Google Account:
   ```bash
   gcloud auth login
   ```
3. Set **Application Default Credentials (ADC)** for Terraform:
   ```bash
   gcloud auth application-default login
   ```
4. Set your active GCP Project ID:
   ```bash
   gcloud config set project YOUR_GCP_PROJECT_ID
   ```
Now Terraform will automatically authenticate using your GCP credentials!

---

### Method B: Using a Service Account JSON Key
1. Go to GCP Console > **IAM & Admin** > **Service Accounts** > Click **Create Service Account**.
2. Name it `terraform-sa` and assign the role **Editor** or **Compute Admin**.
3. Create a **JSON Key** and save it to your machine (e.g. `gcp-key.json`).
4. Set the environment variable in your terminal:
   - **Linux / macOS**:
     ```bash
     export GOOGLE_APPLICATION_CREDENTIALS="/path/to/gcp-key.json"
     ```
   - **Windows (PowerShell)**:
     ```powershell
     $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\gcp-key.json"
     ```

---

## 🚀 2. Running Terraform Locally

```bash
cd infra

# 1. Copy sample variables file
cp terraform.tfvars.example terraform.tfvars

# 2. Edit terraform.tfvars and set your gcp_project_id
# gcp_project_id = "your-actual-gcp-project-id"

# 3. Initialize, plan, and apply
terraform init
terraform plan
terraform apply -auto-approve
```

---

## 🤖 3. Automated GitHub Actions CI/CD Pipeline

The repository includes a pre-configured GitHub Actions workflow in [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml).

### Setting up GitHub Secrets:
1. Go to your GitHub repository > **Settings** > **Secrets and variables** > **Actions**.
2. Add the following **Repository Secrets**:

| Secret Name | Description | Value |
| :--- | :--- | :--- |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `your-gcp-project-id` |
| `GCP_SA_KEY` | Contents of your GCP Service Account JSON key | Copy & paste full contents of `gcp-key.json` |

### How the CI/CD Pipeline Works:
- **Pull Requests**: Runs `terraform fmt` check, `terraform init`, and `terraform plan` to validate changes.
- **Push to `main`**: Automatically runs `terraform apply` to provision/update your $0/mo server on GCP!
