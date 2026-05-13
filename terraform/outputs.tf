output "vm_ip" {
  description = "Public IP of the WarVM server"
  value       = google_compute_address.warvm.address
}

output "web_ui" {
  description = "WarVM landing page"
  value       = "http://${google_compute_address.warvm.address}/"
}

output "novnc_url" {
  description = "Direct noVNC browser remote desktop"
  value       = "http://${google_compute_address.warvm.address}/vm/"
}

output "rdp" {
  description = "RDP connection string"
  value       = "${google_compute_address.warvm.address}:3389"
}

output "ssh" {
  description = "SSH command"
  value       = "ssh ubuntu@${google_compute_address.warvm.address}"
}
