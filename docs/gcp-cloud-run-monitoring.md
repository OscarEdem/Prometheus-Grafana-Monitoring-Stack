# GCP Cloud Run Monitoring Guide (Step-by-Step)                                                                        #*eddiere

## ☁️ Overview: Monitoring GCP Cloud Run in Grafana

Google Cloud Run automatically exports core container performance metrics—such as CPU utilization, RAM usage, request counts, HTTP 4xx/5xx error rates, latency percentiles, and active container instances—directly into **Google Cloud Monitoring** out of the box.

By connecting Grafana directly to **Google Cloud Monitoring**, you can visualize serverless Cloud Run services **side-by-side with your host/EC2 Prometheus metrics** in a single unified Grafana instance without installing extra agents or modifying application code.

---

## 🛠️ Step-by-Step Implementation Guide

Follow these steps to connect GCP Cloud Run to Grafana.

---

### Step 1: Grant IAM Permissions to Grafana

To allow Grafana to fetch metrics from Google Cloud Monitoring, you must grant it the **Monitoring Viewer** IAM role (`roles/monitoring.viewer`) for the target project.

#### Option A: GCE Default Service Account (Recommended - Zero Keys)
If your Grafana instance runs on a GCP Compute Engine VM, it can securely use the VM's GCE metadata server credentials without any JSON key files:

1. **Find the Monitoring VM's Service Account Email**:
   By default, this is the Compute Engine Default Service Account (`PROJECT_NUMBER-compute@developer.gserviceaccount.com`).
2. **Grant Monitoring Viewer Role in the Target Project**:
   Run the following `gcloud` command to grant the monitoring service account access to read metrics from the target project:
   ```bash
   gcloud projects add-iam-policy-binding TARGET_GCP_PROJECT_ID \
       --member="serviceAccount:MONITORING_VM_SA_EMAIL" \
       --role="roles/monitoring.viewer"
   ```

#### Option B: Dedicated Service Account JSON Key (For Local/External Hosting)
If you run Grafana locally or outside of GCP, you must use a dedicated JSON private key:

1. **Create Service Account**:
   ```bash
   gcloud iam service-accounts create grafana-cloud-monitoring-reader \
       --display-name="Grafana Cloud Monitoring Reader" \
       --project=TARGET_GCP_PROJECT_ID
   ```
2. **Assign the Monitoring Viewer IAM Role**:
   ```bash
   gcloud projects add-iam-policy-binding TARGET_GCP_PROJECT_ID \
       --member="serviceAccount:grafana-cloud-monitoring-reader@TARGET_GCP_PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/monitoring.viewer"
   ```
3. **Generate and Download JSON Key**:
   ```bash
   gcloud iam service-accounts keys create ~/grafana-gcp-key.json \
       --iam-account=grafana-cloud-monitoring-reader@TARGET_GCP_PROJECT_ID.iam.gserviceaccount.com
   ```

---

### Step 2: Configure the Google Cloud Monitoring Data Source in Grafana

Grafana can be configured either via the UI or automatically provisioned on startup.

#### Method A: Automated Provisioning (Recommended)
Add the data source directly to your `grafana/provisioning/datasources/datasources.yml` configuration:

```yaml
# --------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                #*eddiere
  - name: Google Cloud Monitoring (CyberAwareness)
    type: stackdriver
    access: proxy
    jsonData:
      authenticationType: gce
      defaultProject: TARGET_GCP_PROJECT_ID
    editable: true
```

#### Method B: Manual Configuration via Grafana UI
1. Open Grafana in your browser at [http://localhost:3001](http://localhost:3001).
2. Log in (Default credentials: `admin` / `admin`).
3. Navigate to **Connections** > **Data Sources** > **+ Add data source** and search for **Google Cloud Monitoring**.
4. Configure the Data Source settings:
   * **Authentication Type**:
     * For **Option A (Zero-Keys)**: Select `GCE Default Service Account`.
     * For **Option B (JSON Key)**: Select `Service Account Key` and paste the contents of `grafana-gcp-key.json`.
   * **Default Project**: Input your target GCP Project ID (e.g., `greencandlecyberawareness`).
5. Click **Save & test**. You should see a green notification: *"Successfully queried the Google Cloud Monitoring API."*

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

---

## 🖥️ Monitoring Private Database VMs (Google Cloud Ops Agent)

For Compute Engine VMs that do not have public IPs (such as `cyberawareness-prod-db-vm` running Postgres), you cannot scrape them directly using the central Prometheus stack. Instead, you can install the **Google Cloud Ops Agent** to push system metrics directly to Google Cloud Monitoring.

### 1. Installation
The Ops Agent can be installed automatically via the VM's startup script:
```bash
# Install Google Cloud Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
```

### 2. Verify Agent Status
SSH into your DB VM and verify the agent is running:
```bash
sudo systemctl status google-cloud-ops-agent"*"
```

### 3. Visualizing VM Metrics in Grafana
Once the Ops Agent starts pushing metrics, they will appear in Google Cloud Monitoring under the `compute.googleapis.com` metric namespace. You can query these metrics in Grafana using the same **Google Cloud Monitoring** data source:
* **CPU Utilization**: `compute.googleapis.com/instance/cpu/utilization`
* **Memory Utilization**: `compute.googleapis.com/instance/memory/percent_used`
* **Disk Write Operations**: `compute.googleapis.com/instance/disk/write_bytes_count`

