# Local Testing & Execution Guide                                                                                        #*eddiere

## 🧪 How to Run and Test This Stack Locally

This guide explains how to spin up the Prometheus + Grafana monitoring stack on your local machine using Docker Desktop or Docker Engine.

---

## 📋 Prerequisites

- **Docker Desktop** installed and running on your system (Windows, macOS, or Linux).
- **Git** (for version control).

---

## 🚀 Step 1: Start the Monitoring Stack

Open your terminal in the `monitoring/` directory and execute:

```bash
docker compose up -d
```

### Expected Output:
```text
[+] Running 5/5
 ✔ Network monitoring_default        Created
 ✔ Container local_prometheus        Started
 ✔ Container local_grafana           Started
 ✔ Container local_node_exporter     Started
 ✔ Container local_cadvisor          Started
```

---

## 🔍 Step 2: Verify Container Health

Run the status command:
```bash
docker compose ps
```

Ensure all 4 containers show status `Up` or `Running`:

| Container Name | Service | Published Port | Health Endpoint |
| :--- | :--- | :--- | :--- |
| `local_prometheus` | Prometheus | `9090` | [http://localhost:9090](http://localhost:9090) |
| `local_grafana` | Grafana | `3001` | [http://localhost:3001](http://localhost:3001) |
| `local_node_exporter` | Node Exporter | `9100` | [http://localhost:9100/metrics](http://localhost:9100/metrics) |
| `local_cadvisor` | cAdvisor | `8080` | [http://localhost:8080/metrics](http://localhost:8080/metrics) |

---

## 📊 Step 3: Configure Grafana Dashboards

### 1. Log In to Grafana
- Navigate to **[http://localhost:3001](http://localhost:3001)**
- Default Username: `admin`
- Default Password: `admin` *(You will be prompted to set a new password on first login).*

### 2. Connect Prometheus Data Source
1. Click **Connections** > **Data Sources** > **Add Data Source**.
2. Select **Prometheus**.
3. In **Prometheus server URL**, enter:
   `http://prometheus:9090`
4. Scroll down and click **Save & Test**. You should see a green confirmation badge.

### 3. Import Recommended Pre-Built Dashboards
Instead of building charts manually:
1. Go to **Dashboards** > **New** > **Import**.
2. Enter **Dashboard ID `1860`** (Node Exporter Full - Host CPU, RAM, Disk & Network) and click **Load**.
3. Select your `Prometheus` data source and click **Import**.
4. Repeat for **Dashboard ID `14282`** (cAdvisor / Docker Container Metrics).

---

## 🛑 Step 4: Stopping and Managing the Stack

```bash
# View real-time container logs
docker compose logs -f

# Stop containers (preserves Grafana volume data)
docker compose down

# Stop containers and remove volumes (fresh reset)
docker compose down -v

# Restart services after updating prometheus.yml
docker compose restart prometheus
```
