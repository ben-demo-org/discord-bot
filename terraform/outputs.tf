output "service_url" {
  value = google_cloud_run_v2_service.default.traffic_statuses[0].url
}