# Short description of the use case in comments

locals {
  project_id = "padok-cloud-factory"
}

provider "google" {
  region = "europe-west1"
}

resource "google_compute_managed_ssl_certificate" "this" {
  name    = "playground-tls"
  project = local.project_id
  managed {
    domains = ["frontend-library.playground.padok.cloud", "www.frontend-library.playground.padok.cloud"]
  }
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
      bucket_name = google_storage_bucket.this.name
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
  ssl_certificates    = [google_compute_managed_ssl_certificate.this.id]
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

resource "google_storage_bucket" "this" {
  name     = "example-custom-certificate"
  project  = local.project_id
  location = "EU"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}
