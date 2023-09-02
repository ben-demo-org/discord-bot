terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.80.0"
    }
    required_version = "1.5.5"
  }
}

provider "google" {}