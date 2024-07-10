provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

data "google_client_config" "default" {}

resource "google_container_cluster" "primary" {
  name     = "primary-cluster"
  location = var.region

  # Disable deletion protection
  deletion_protection = false
  
  node_config {
    machine_type = "e2-medium"
  }

  initial_node_count = 1
}

output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}

output "region" {
  value = var.region
}
