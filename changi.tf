terraform {
  backend "remote" {
    organization = "jiayu"

    workspaces {
      name = "changi"
    }
  }
}

variable "image" {
  type    = string
  default = "gcr.io/infra-248610/github.com/yi-jiayu/changi@sha256:c90c93fc651be1456f86b9eff8fd6d7c442e0bbb48bffffd420befe9a771e73e"
}

resource "kubernetes_ingress" "changi" {
  metadata {
    name = "changi"

    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }

  spec {
    rule {
      host = "changi.kembangan.infra.jiayu.io"

      http {
        path {
          backend {
            service_name = kubernetes_service.changi.metadata.0.name
            service_port = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "changi" {
  metadata {
    name = "changi"

    labels = {
      app = kubernetes_deployment.changi.metadata.0.labels.app
    }
  }

  spec {
    port {
      name        = "http"
      port        = 80
      target_port = "8080"
    }

    selector = {
      app = "changi"
    }
  }
}

resource "kubernetes_deployment" "changi" {
  metadata {
    name      = "changi"
    namespace = "default"

    labels = {
      app = "changi"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "changi"
      }
    }

    template {
      metadata {
        labels = {
          app = "changi"
        }
      }

      spec {
        container {
          name  = "changi"
          image = var.image

          readiness_probe {
            http_get {
              path   = "/ping"
              port   = "8080"
              scheme = "HTTP"
            }
          }
        }
      }
    }
  }
}
