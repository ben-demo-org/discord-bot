data "google_client_config" "current" {}

# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

resource "google_cloud_run_v2_service" "run_service" {
  name     = "jmusicbot"
  location = data.google_client_config.current.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    volumes {
      name = "a-volume"
      secret {
        secret = google_secret_manager_secret.secret.secret_id
        items {
          version = "latest"
          path    = "config.txt"
          mode    = 0
        }
      }
    }
    containers {
      ports {
        container_port = 56216
      }
      startup_probe {
        initial_delay_seconds = 10
        timeout_seconds       = 1
        period_seconds        = 3
        failure_threshold     = 3
        tcp_socket {
          port = 56216
        }
      }
      image = "craumix/jmusicbot"
      volume_mounts {
        name       = "a-volume"
        mount_path = "/jmb/config"
      }
    }
  }
  depends_on = [google_secret_manager_secret_version.secret-version-data]
}

data "google_project" "project" {
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "jmusic-config"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret-version-data" {
  secret      = google_secret_manager_secret.secret.name
  secret_data = var.configdata
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id  = google_secret_manager_secret.secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.secret]
}

resource "google_cloud_run_v2_service_iam_member" "run_all_users" {
  project  = google_cloud_run_v2_service.run_service.project
  location = google_cloud_run_v2_service.run_service.location
  name     = google_cloud_run_v2_service.run_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}