# GCP Cloud Run Monitoring Guide (Step-by-Step)                                                                        #*eddiere

## ☁️ Overview: Monitoring GCP Cloud Run in Grafana

Google Cloud Run automatically exports core container performance metrics—such as CPU utilization, RAM usage, request counts, HTTP 4xx/5xx error rates, latency percentiles, and active container instances—directly into **Google Cloud Monitoring** out of the box.

By connecting Grafana directly to **Google Cloud Monitoring**, you can visualize serverless Cloud Run services **side-by-side with your host/EC2 Prometheus metrics** in a single unified Grafana instance without installing extra agents or modifying application code.

---

## 🛠️ Step-by-Step Implementation Guide

Follow these steps to connect GCP Cloud Run to Grafana.

---

### Step 1: Create a GCP Service Account & Assign IAM Roles

To allow Grafana to fetch metrics from Google Cloud Monitoring, create a Service Account with read-only monitoring permissions.

#### Option A: Using `gcloud` CLI (Recommended)

Run the following commands in your terminal or Google Cloud Shell:

```bash
# 1. Set your target Google Cloud Project ID
gcloud config set project YOUR_GCP_PROJECT_ID

# 2. Create a dedicated Service Account for Grafana
gcloud iam service-accounts create grafana-cloud-monitoring-reader \
    --display-name="Grafana Cloud Monitoring Reader"

# 3. Assign the 'Monitoring Viewer' IAM role
gcloud projects add-iam-policy-binding YOUR_GCP_PROJECT_ID \
    --member="serviceAccount:grafana-cloud-monitoring-reader@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/monitoring.viewer"

# 4. Generate and download the JSON service account key
gcloud iam service-accounts keys create ~/grafana-gcp-key.json \
    --iam-account=grafana-cloud-monitoring-reader@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com
```

#### Option B: Using Google Cloud Console (GUI)

1. Open **Google Cloud Console** > **IAM & Admin** > **Service Accounts**.
2. Click **+ Create Service Account**.
3. Set Name: `grafana-cloud-monitoring-reader` and click **Create and Continue**.
4. In **Grant this service account access to project**, select Role: **Monitoring** > **Monitoring Viewer** (`roles/monitoring.viewer`).
5. Click **Done**.
6. Select your new Service Account > **Keys** tab > **Add Key** > **Create new key**.
7. Choose **JSON** format and save `grafana-gcp-key.json` to your local machine.

---

### Step 2: Add Google Cloud Monitoring Data Source in Grafana

1. Open Grafana in your browser at [http://localhost:3001](http://localhost:3001).
2. Log in (Default credentials: `admin` / `admin`).
3. In the left navigation bar, go to **Connections** > **Data Sources**.
4. Click **+ Add data source** and search for **Google Cloud Monitoring**.
5. Configure the Data Source settings:
   - **Authentication Type**: Select `Service Account Key`.
   - **Service Account Key**: Open your downloaded `grafana-gcp-key.json` file, copy its entire JSON content, and paste it into the field.
   - **Default Project**: Select your GCP Project ID.
6. Click **Save & test**.
7. You should see a green notification: *"Successfully queried the Google Cloud Monitoring API."*

---

### Step 3: Key GCP Cloud Run Metrics to Visualize

Once connected, Grafana gains access to all built-in Cloud Run metrics under the `run.googleapis.com` metric namespace:

| Metric Name in Grafana | Description | Use Case |
| :--- | :--- | :--- |
| `run.googleapis.com/container/cpu/utilization` | CPU percentage consumed by Cloud Run container instances. | Track CPU bottlenecks & auto-scaling triggers. |
| `run.googleapis.com/container/memory/utilization` | Memory percentage used vs. allocated limit. | Detect out-of-memory (OOM) risks. |
| `run.googleapis.com/request_count` | Total HTTP requests processed, filterable by `response_code_class` (2xx, 4xx, 5xx). | Monitor traffic spikes & error rates. |
| `run.googleapis.com/request_latencies` | End-to-end request handling time (p50, p95, p99 percentiles). | Measure user-perceived performance. |
| `run.googleapis.com/container/instance_count` | Number of active, billable, and idle container instances. | Cost optimization & scale-to-zero tracking. |
| `run.googleapis.com/container/billable_instance_time` | Total billable execution time in seconds. | Track Cloud Run cloud spending. |

---

### Step 4: Import Pre-Built Cloud Run Grafana Dashboards

Instead of creating panels from scratch, you can import community dashboards pre-configured for Cloud Run:

1. In Grafana, click **Dashboards** > **New** > **Import**.
2. Enter one of the following official Dashboard IDs:
   - **Dashboard ID `11073`**: *Google Cloud Run Overview*
   - **Dashboard ID `10962`**: *GCP Cloud Run Service Metrics*
3. Select your **Google Cloud Monitoring** data source from the dropdown.
4. Click **Import**.

---

### Step 5: Unified Side-by-Side Dashboard (EC2 / VPS + GCP Cloud Run)

You can now combine panels from different data sources into a **single unified Grafana dashboard**:

```text
+------------------------------------------------------------------------------------+
|                         UNIFIED INFRASTRUCTURE DASHBOARD                           |
+--------------------------------------------------+---------------------------------+
| LOCAL / EC2 HOST HEALTH (Prometheus DS)          | GCP CLOUD RUN SERVICES (GCP DS) |
| - Host CPU Usage (node_exporter:9100)            | - Cloud Run CPU Utilization     |
| - Host Memory Consumption                        | - Active Container Instances    |
| - Docker Container CPU & RAM (cAdvisor:8080)     | - HTTP 2xx/4xx/5xx Request Rate |
+--------------------------------------------------+---------------------------------+
```

---

## ⚡ Alternative Cloud Run Monitoring Options

If you require custom application metrics or enterprise-wide metrics collection, refer to these alternative approaches:

### Option 2: Prometheus Pushgateway (For Custom Code Metrics)
- **Use Case**: Pushing custom business metrics (e.g. `orders_processed_total`) from ephemeral Cloud Run functions.
- **Architecture**: `[Cloud Run App] --(HTTP POST)--> [Pushgateway:9091] <-- (Scrape) <-- [Prometheus:9090]`
- **Setup**: Add `prom/pushgateway:latest` to `docker-compose.yml` and use `prom-client` (Node.js) or `prometheus_client` (Python) in your app code.

### Option 3: Google Cloud Managed Service for Prometheus (GMP)
- Fully-managed Prometheus agent ingestion native to Google Cloud, queried directly via Grafana using standard PromQL.
