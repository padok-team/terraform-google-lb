# Short description of the use case in comments

provider "google" {
  region  = "europe-west1"
  project = "padok-cloud-factory"
}

data "google_project" "this" {}

locals {
  domain_name = "googlelb.padok.cloud"
}

# --- Generate Certificate --- #
resource "google_compute_managed_ssl_certificate" "this" {
  project = data.google_project.this.project_id

  name = replace(local.domain_name, ".", "-")
  managed {
    domains = [local.domain_name]
  }
}

module "custom_cdn_policy_lb" {
  source = "../.."

  name       = "lb-library"
  project_id = data.google_project.this.project_id

  buckets_backends = {
    frontend = {
      hosts = ["frontend-library.playground.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = "padok-helm-library"
      cdn_policy  = "custom_react"
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
  ssl_certificates = [google_compute_managed_ssl_certificate.this.id]
  custom_cdn_policies = {
    custom_react = {
      cache_mode       = "USE_ORIGIN_HEADERS"
      negative_caching = true
      negative_caching_policy = {
        "404" = {
          code = "404"
          ttl  = "1"
        },
        "302" = {
          code = "302"
          ttl  = "1"
        },
      }
    },
  }
}

resource "google_compute_region_network_endpoint_group" "backend" {
  name                  = "network-backend"
  project               = data.google_project.this.project_id
  region                = "europe-west1"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = "echoserver"
  }
}

