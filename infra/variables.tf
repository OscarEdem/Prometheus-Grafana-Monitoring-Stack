# --------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                #*eddiere
variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID where the monitoring stack VM will be provisioned."
}

variable "gcp_region" {
  type        = string
  description = "GCP Region for the Always Free instance (e.g. us-central1, us-west1, us-east1)."
  default     = "us-central1"
}

variable "gcp_zone" {
  type        = string
  description = "GCP Zone for the VM instance."
  default     = "us-central1-a"
}

variable "repository_url" {
  type        = string
  description = "Git repository URL containing the Prometheus + Grafana stack."
  default     = "https://github.com/OscarEdem/Prometheus-Grafana-Monitoring-Stack.git"
}
