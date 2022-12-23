# Short description of the use case in comments

locals {
  project_id = "padok-cloud-factory"
}

provider "google" {
  region = "europe-west1"
}

module "multi_backend_lb" {
  source = "../.."

  name       = "lb-library"
  project_id = local.project_id

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
  ssl_certificates    = []
  custom_cdn_policies = {}
}

resource "google_compute_region_network_endpoint_group" "backend" {
  name    = "network-backend"
  project = local.project_id

  region                = "europe-west1"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = "echoserver"
  }
}

