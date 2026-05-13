variable "project_id" {
  description = "Your GCP project ID (find it at console.cloud.google.com)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone (must support nested virtualisation)"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCE machine type — n2-standard-4 gives 4 vCPU / 16 GB RAM"
  type        = string
  default     = "n2-standard-4"
}

variable "warvm_password" {
  description = "Windows login password (also used for the VM web UI)"
  type        = string
  default     = "WarThunder1!"
  sensitive   = true
}
