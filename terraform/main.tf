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
        secret       = google_secret_manager_secret.secret.secret_id
        default_mode = 0400
        items {
          version = "1"
          path    = "config.txt"
          mode    = 0400
        }
      }
    }
    containers {
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
  service  = google_cloud_run_v2_service.run_service.name
  location = google_cloud_run_v2_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}