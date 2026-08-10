# Multi-Project Capacity & Scalability Guide                                                                             #*eddiere

## 📊 How Many Projects Can You Monitor?

**Short Answer**: A single instance of this Prometheus + Grafana stack can monitor **dozens of independent projects and hundreds of containers** simultaneously on your server with minimal hardware overhead (~350 MB – 500 MB RAM).

---

## 🔍 How Multi-Project Monitoring Works

### 1. Automatic Docker Container Auto-Discovery (via cAdvisor)
`cAdvisor` hooks directly into the host machine's Docker daemon (`/var/lib/docker` and `/var/run`).
- Every container deployed on the host—regardless of which project it belongs to (e.g., `storefront-frontend`, `admin-backend`, `redis-cache`, `postgres-db`)—is **automatically detected and monitored**.
- Container metrics tracked include:
  - CPU usage (`container_cpu_usage_seconds_total`)
  - RAM consumption (`container_memory_usage_bytes`)
  - Network ingress/egress (`container_network_receive_bytes_total`)
  - Disk I/O read/write (`container_fs_reads_total`)

### 2. Multi-Project Segmentation in Grafana
In Grafana, all containers are distinguishable using labels:
- `name`: Name of the Docker container (e.g., `local_grafana`, `afrovogue-api-green`).
- `image`: Docker image tag.
- `container_label_*`: Any custom Docker labels applied in your `docker-compose.yml`.

#### Filtering Dashboards by Project:
You can build a single Grafana dashboard with a **Project Dropdown** variable:
```promql
# Metric query for a specific container/project:
container_memory_usage_bytes{name=~"project-a-.*"}
```

---

## 🚀 Monitoring Custom Application Code Metrics

Besides container health, you can scrape custom application-level metrics (e.g., HTTP response status counts, API request latency, database query times) from your code across multiple projects.

### Step 1: Expose `/metrics` in Your App
Most frameworks have official Prometheus client libraries:
- **Node.js / Express / Next.js**: `prom-client`
- **Python / FastAPI / Django**: `prometheus_client` or `starlette-prometheus`
- **Go**: `prometheus/client_golang`

### Step 2: Add Scrape Jobs in `prometheus.yml`
Add each project's endpoint as a scrape target in `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'ec2-host-metrics'
    static_configs:
      - targets: ['node_exporter:9100']

  - job_name: 'ec2-container-metrics'
    static_configs:
      - targets: ['cadvisor:8080']

  # Project 1: E-Commerce Storefront API
  - job_name: 'storefront-api'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['host.docker.internal:8000']

  # Project 2: Admin Dashboard API
  - job_name: 'admin-api'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['host.docker.internal:8001']
```

---

## 🌐 Multi-Server & Remote Host Scale

Can this stack monitor multiple physical servers / EC2 instances? **Yes.**
- You only need **one** central Prometheus + Grafana server.
- On each remote server you wish to monitor, run lightweight `node_exporter` (and `cAdvisor` if using Docker).
- Point central `prometheus.yml` targets to the remote IP addresses:

```yaml
  - job_name: 'remote-ec2-production'
    static_configs:
      - targets: ['54.123.45.67:9100', '54.123.45.68:9100']
```

---

## 📈 Scalability Limits Summary

| Resource | Single Prometheus Instance Limit | Recommendation |
| :--- | :--- | :--- |
| **Monitored Containers** | Up to ~500 containers | Keep 15s scrape interval |
| **Monitored Servers** | 20 – 50 remote servers | Allocate ~2 GB RAM to Prometheus if > 50 servers |
| **Metrics Data Retention** | Default 15 days | Adjust storage size or retention (`--storage.tsdb.retention.time=30d`) |
