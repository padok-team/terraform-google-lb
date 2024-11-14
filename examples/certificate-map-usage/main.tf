# This example creates a SSL certificate and attach it to e new load balancer

locals {
  project_id = "padok-cloud-factory"
  domains = {
    frontend = "frontend-library.playground.padok.cloud"
    www      = "www.frontend-library.playground.padok.cloud"
  }
}

provider "google" {
  region = "europe-west1"
}

terraform {
  required_version = "~> 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}


resource "google_certificate_manager_certificate_map" "this" {
  name    = "playground-tls"
  project = local.project_id
  labels = {
    "terraform" : true
  }
}

resource "google_certificate_manager_certificate" "these" {
  for_each    = local.domains
  project     = local.project_id
  name        = each.key
  description = "Cert with LB authorization"
  managed {
    domains = [each.value]
  }
  labels = {
    "terraform" : true
  }
}

resource "google_certificate_manager_certificate_map_entry" "these" {
  for_each     = local.domains
  name         = each.key
  project      = local.project_id
  map          = google_certificate_manager_certificate_map.this.name
  certificates = [google_certificate_manager_certificate.these[each.key].id]
  hostname     = each.value.domain
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
  certificate_map_id  = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.this.id}"
  custom_cdn_policies = {}
}

resource "google_storage_bucket" "this" {
  name     = "example-custom-certificate"
  project  = local.project_id
  location = "EU"
  #checkov:skip=CKV_GCP_62: Example, no connexion logging required
  #checkov:skip=CKV_GCP_78: Example, no versioning required

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}
