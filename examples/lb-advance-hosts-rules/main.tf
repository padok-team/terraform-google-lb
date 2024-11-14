# This example creates a SSL certificate and attach it to e new load balancer

locals {
  project_id      = "padok-cloud-factory"
  domains_library = ["library.playground.padok.cloud", "www.library.playground.padok.cloud"]
}

provider "google" {
  region = "europe-west1"
}

provider "google-beta" {
  region = "europe-west1"
}

terraform {
  required_version = "~> 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
  }
}


resource "google_compute_managed_ssl_certificate" "this" {
  name    = "playground-tls"
  project = local.project_id
  managed {
    domains = local.domains_library
  }
}

module "my_lb" {
  source = "../.."

  name       = "my-lb"
  project_id = local.project_id

  advance_hosts_rules = {
    library = {
      hosts              = local.domains_library
      default_service_id = google_compute_backend_bucket.this.id
      path_rules = [
        {
          paths      = ["/*"]
          service_id = google_compute_backend_bucket.this.id
        },
        {
          paths      = ["/api/*"]
          service_id = google_compute_backend_service.this.id
        }
      ]
    }
  }

  ssl_certificates = [google_compute_managed_ssl_certificate.this.id]

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

resource "google_compute_region_network_endpoint_group" "this" {
  provider              = google-beta
  project               = local.project_id
  name                  = "my-cloud-run-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "europe-west1"
  cloud_run {
    service = "library"
  }
}

resource "google_compute_backend_service" "this" {
  name    = "my-cloud-run"
  project = local.project_id

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.this.id
  }
}

resource "google_compute_backend_bucket" "this" {
  name    = "example-custom-certificate"
  project = local.project_id


  bucket_name = google_storage_bucket.this.name
}
