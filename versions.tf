terraform {
  required_version = ">= 1.3.0"
  cloud {
    organization = "cklewar"
    hostname     = "app.terraform.io"

    workspaces {
      name = "gcp-compute-module"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.39.0"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}