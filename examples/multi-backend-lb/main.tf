# Short description of the use case in comments

provider "google" {
  project = "padok-cloud-factory"
  region  = "europe-west1"
}

data "google_compute_ssl_certificate" "playground" {
  name = "playground-tls"
}

module "multi_backend_lb" {
  source = "../.."

  name = "lb-library"

  buckets_backends = {
    frontend = {
      hosts = ["frontend-library.playground.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = "padok-helm-library"
    }
  }
  service_backends = {
    backend = {
      hosts = ["echo.playground.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      groups = [google_compute_region_network_endpoint_group.backend.id]
    }
  }
  ssl_certificates    = [data.google_compute_ssl_certificate.playground.self_link]
  custom_cdn_policies = {}
}

resource "google_compute_region_network_endpoint_group" "backend" {
  name                  = "network-backend"
  region                = "europe-west1"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = "echoserver"
  }
}

