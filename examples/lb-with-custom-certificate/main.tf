# This example creates a SSL certificate and attach it to e new load balancer

locals {
  domain_name = "googlelb.padok.cloud"
  project_id  = "padok-cloud-factory"
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

module "my_lb" {
  source = "../.."

  name       = "my-lb"
  project_id = local.project_id

  buckets_backends = {
    frontend = {
      hosts = ["frontend-library.playground.padok.cloud", "www.frontend-library.playground.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = google_storage_bucket.this.name
    }
  }
  service_backends    = {}
  ssl_certificates    = [google_compute_managed_ssl_certificate.this.id]
  custom_cdn_policies = {}
}

resource "google_storage_bucket" "this" {
  name     = "example-custom-certificate"
  project  = local.project_id
  location = "EU"
  #checkov:skip=CKV_GCP_62: Example, no connexion logging required
  #checkov:skip=CKV_GCP_78: Example, no versioning required

  public_access_prevention = "enforced"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}
