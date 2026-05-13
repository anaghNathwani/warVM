terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ── Networking ────────────────────────────────────────────────────────────────
resource "google_compute_network" "warvm" {
  name                    = "warvm-network"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "warvm_allow" {
  name    = "warvm-allow"
  network = google_compute_network.warvm.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389", "8006"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["warvm"]
}

# ── Static IP ─────────────────────────────────────────────────────────────────
resource "google_compute_address" "warvm" {
  name   = "warvm-ip"
  region = var.region
}

# ── Boot disk (120 GB SSD) ────────────────────────────────────────────────────
resource "google_compute_disk" "warvm" {
  name  = "warvm-disk"
  type  = "pd-ssd"
  zone  = var.zone
  size  = 150
  image = "ubuntu-os-cloud/ubuntu-2204-lts"
}

# ── VM instance (nested virt enabled for KVM) ─────────────────────────────────
resource "google_compute_instance" "warvm" {
  name         = "warvm-server"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["warvm"]

  # Nested virtualisation is required for KVM inside GCE
  advanced_machine_features {
    enable_nested_virtualization = true
  }

  boot_disk {
    source      = google_compute_disk.warvm.self_link
    auto_delete = false   # keep disk on destroy so game data survives
  }

  network_interface {
    network = google_compute_network.warvm.name
    access_config {
      nat_ip = google_compute_address.warvm.address
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      warvm_password = var.warvm_password
    })
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
