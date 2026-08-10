# --------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                #*eddiere
variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID where the monitoring stack VM will be provisioned."
}

variable "gcp_region" {
  type        = string
  description = "GCP Region for the Always Free instance (e.g. us-west1, us-central1, us-east1)."
  default     = "us-west1"
}

variable "gcp_zone" {
  type        = string
  description = "GCP Zone for the VM instance."
  default     = "us-west1-b" # Switched to Oregon us-west1-b for high capacity & Always Free ($0/mo) eligibility
}

variable "repository_url" {
  type        = string
  description = "Git repository URL containing the Prometheus + Grafana stack."
  default     = "https://github.com/OscarEdem/Prometheus-Grafana-Monitoring-Stack.git"
}
