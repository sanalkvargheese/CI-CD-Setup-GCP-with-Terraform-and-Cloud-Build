provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name = "cloudsql-db-credentials"
  }

  data = {
    DB_USER = "admin"
    DB_PASS = "admin"
    DB_HOST = "34.134.177.160"
  }
}

resource "kubernetes_deployment" "flask_app" {
  metadata {
    name = "flask-app"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "flask-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }

      spec {
        container {
          name  = "flask-app"
          image = "gcr.io/cloudone-123/flask:latest"
          port {
            container_port = 5000
          }
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = "cloudsql-db-credentials"
                key  = "DB_USER"
              }
            }
          }
          env {
            name = "DB_PASS"
            value_from {
              secret_key_ref {
                name = "cloudsql-db-credentials"
                key  = "DB_PASS"
              }
            }
          }
          env {
            name = "DB_HOST"
            value_from {
              secret_key_ref {
                name = "cloudsql-db-credentials"
                key  = "DB_HOST"
              }
            }
          }
          env {
            name  = "DB_NAME"
            value = "admin"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_service" {
  metadata {
    name = "flask-service"
  }

  spec {
    selector = {
      app = "flask-app"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}


resource "kubernetes_deployment" "react_app" {
  metadata {
    name = "react-app"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "react-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "react-app"
        }
      }

      spec {
        container {
          name  = "react-app"
          image = "gcr.io/cloudone-123/react:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "react_service" {
  metadata {
    name = "react-service"
  }

  spec {
    selector = {
      app = "react-app"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
