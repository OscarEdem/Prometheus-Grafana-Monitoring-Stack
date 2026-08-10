# Render 100% Free Tier Deployment Guide ($0/month)                                                                   #*eddiere

This guide explains how to deploy **Grafana** and **Prometheus** on **Render Cloud** completely **FREE ($0.00 / month)**.

---

## 💰 Price Comparison

| Plan | Monthly Cost | Web Services | Persistent Disks |
| :--- | :--- | :--- | :--- |
| **Render Starter Plan** | `$17.75 / month` | 2 x $7 Starter services | 2 x Paid persistent disks |
| **Render Free Plan** | **`$0.00 / month`** | **2 x Free Web Services** | **Ephemeral storage ($0)** |

---

## ⚡ How the 100% Free Plan Works

1. **Free Instance Type (`plan: free`)**:
   Both Grafana (`grafana-monitoring-ui`) and Prometheus (`prometheus-time-series-db`) are configured as **Free Web Services**.
2. **Ephemeral Disk ($0 Storage)**:
   Removed paid persistent storage disks ($3.75/mo value) to eliminate all billing. Data is stored directly within the container filesystem.

---

## 🚀 One-Click Deploy ($0/Month Blueprint)

1. Push your updated code to GitHub:
   ```bash
   git add render.yaml
   git commit -m "update: configure 100% free tier plan"
   git push origin main
   ```
2. Log in to [Render Dashboard](https://dashboard.render.com).
3. Click **New +** > **Blueprint**.
4. Select your GitHub repository: `OscarEdem/Prometheus-Grafana-Monitoring-Stack`.
5. Render will detect [`render.yaml`](../render.yaml) and show:
   - **`grafana-monitoring-ui`**: `Free ($0/mo)`
   - **`prometheus-time-series-db`**: `Free ($0/mo)`
   - **Total**: **`$0.00 / month`**
6. Click **Apply**.

---

## 💡 Keeping Free Instances Awake 24/7 (Free Pinger)

Render's free web services automatically enter sleep mode after **15 minutes of inactivity** if no HTTP requests are received.

### Solution for 24/7 Uptime at $0 Cost:
Set up a free ping monitor (e.g., [UptimeRobot.com](https://uptimerobot.com) or [Cron-job.org](https://cron-job.org)) to send an HTTP GET request to your Render URLs every 10–14 minutes:
- `https://grafana-monitoring-ui.onrender.com`
- `https://prometheus-time-series-db.onrender.com`

This keeps both containers active and scraping 24/7 for **$0.00 / month**.
