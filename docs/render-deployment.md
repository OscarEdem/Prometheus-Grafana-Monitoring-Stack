# Render Cloud Hosting & Deployment Guide                                                                              #*eddiere

This guide explains step-by-step how to deploy **Grafana** and **Prometheus** on **Render Cloud** using the included [`render.yaml`](../render.yaml) Blueprint file or manual Render setup.

---

## ⚡ Deployment Architecture on Render

```text
                                [ RENDER CLOUD PLATFORM ]
 ┌───────────────────────────────────────────────────────────────────────────────────────┐
 │                                                                                       │
 │   ┌──────────────────────────────┐              ┌─────────────────────────────────┐   │
 │   │  Grafana Web Service         │              │  Prometheus Private Service     │   │
 │   │  (Public Dashboard UI)       │ ────────────>│  (Internal Metrics Storage)     │   │
 │   │  - Port 3000                 │ Internal Net │  - Port 9090                    │   │
 │   │  - Persistent Disk (5 GB)    │              │  - Persistent Disk (10 GB)      │   │
 │   └──────────────────────────────┘              └─────────────────────────────────┘   │
 │                                                                 ▲                     │
 └─────────────────────────────────────────────────────────────────┼─────────────────────┘
                                                                   │
                                             Scrapes External / Cloud Targets
                                                                   │
                         ┌─────────────────────────────────────────┴────────────────────────────────────────┐
                         │                                                                                  │
                         ▼                                                                                  ▼
            ┌──────────────────────────┐                                                   ┌──────────────────────────┐
            │ Production EC2 / VPS     │                                                   │ GCP Cloud Run            │
            │ - Node Exporter (:9100)  │                                                   │ - Google Cloud           │
            │ - cAdvisor (:8080)       │                                                   │   Monitoring Plugin      │
            └──────────────────────────┘                                                   └──────────────────────────┘
```

---

## 🚀 Option 1: One-Click Deploy via Render Blueprint (`render.yaml`)

The repository includes a ready-to-deploy [`render.yaml`](../render.yaml) specification.

### Step-by-Step Blueprint Deployment:
1. Push this repository to GitHub (`OscarEdem/Prometheus-Grafana-Monitoring-Stack`).
2. Log in to [Render Dashboard](https://dashboard.render.com).
3. Click **New +** > **Blueprint**.
4. Connect your GitHub repository `Prometheus-Grafana-Monitoring-Stack`.
5. Render will automatically detect [`render.yaml`](../render.yaml) and provision:
   - **`grafana-monitoring-ui`** (Public Web Service with 5 GB persistent disk mounted at `/var/lib/grafana`).
   - **`prometheus-time-series-db`** (Private Service with 10 GB persistent disk mounted at `/prometheus`).
6. Click **Apply**. Render will build and launch both services automatically!

---

## 🛠️ Option 2: Manual Render Service Setup

If you prefer to configure services manually via the Render UI:

### 1. Deploy Grafana (Web Service)
1. In Render Dashboard, click **New +** > **Web Service**.
2. Connect your GitHub repository.
3. Configure settings:
   - **Name**: `grafana-monitoring-ui`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `./Dockerfile.grafana`
   - **Instance Type**: Starter ($7/mo or Free tier for testing).
4. Add **Environment Variables**:
   - `PORT`: `3000`
   - `GF_USERS_ALLOW_SIGN_UP`: `false`
   - `GF_SECURITY_ADMIN_PASSWORD`: *(Set a strong password)*
5. Add **Persistent Disk** *(Crucial for dashboard saving)*:
   - Name: `grafana-storage`
   - Mount Path: `/var/lib/grafana`
   - Size: `5 GB`
6. Click **Create Web Service**.

---

### 2. Deploy Prometheus (Private Service)
1. In Render Dashboard, click **New +** > **Private Service**.
2. Connect your repository.
3. Configure settings:
   - **Name**: `prometheus-time-series-db`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `./Dockerfile.prometheus`
4. Add **Environment Variables**:
   - `PORT`: `9090`
5. Add **Persistent Disk**:
   - Name: `prometheus-storage`
   - Mount Path: `/prometheus`
   - Size: `10 GB`
6. Click **Create Private Service**.

---

## 🔗 Connecting Grafana to Prometheus on Render

1. Open your Grafana public URL provided by Render (e.g., `https://grafana-monitoring-ui.onrender.com`).
2. Log in using `admin` and the password set in `GF_SECURITY_ADMIN_PASSWORD`.
3. Go to **Connections** > **Data Sources** > **Add Data Source** > **Prometheus**.
4. Set the Server URL to the internal Render private service hostname:
   `http://prometheus-time-series-db:9090`
5. Click **Save & Test**.

---

## ⚠️ Important Note on `node_exporter` & `cAdvisor`

Render runs applications inside isolated container microVM sandboxes and **does not expose raw host root access** (`/proc`, `/sys`, `/var/run/docker.sock`).

- **Where to run exporters**: Keep `node_exporter` and `cAdvisor` running on your production server instances (e.g. AWS EC2, DigitalOcean, Hetzner, or local host).
- **Prometheus Scrape Config**: In your [`prometheus.yml`](../prometheus.yml), set scrape targets pointing to the public IP/domain of your production servers:
  ```yaml
  scrape_configs:
    - job_name: 'production-ec2'
      static_configs:
        - targets: ['your-ec2-ip:9100']
  ```
