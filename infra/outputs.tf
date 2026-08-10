# --------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                #*eddiere
output "vm_name" {
  value       = google_compute_instance.monitoring_vm.name
  description = "The name of the provisioned GCP Compute Engine instance."
}

output "vm_public_ip" {
  value       = google_compute_instance.monitoring_vm.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the monitoring server."
}

output "grafana_url" {
  value       = "http://${google_compute_instance.monitoring_vm.network_interface[0].access_config[0].nat_ip}:3001"
  description = "Public URL to access Grafana Dashboard UI."
}

output "prometheus_url" {
  value       = "http://${google_compute_instance.monitoring_vm.network_interface[0].access_config[0].nat_ip}:9090"
  description = "Public URL to access Prometheus UI."
}
