terraform {
  required_version = "~> 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.81"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}
