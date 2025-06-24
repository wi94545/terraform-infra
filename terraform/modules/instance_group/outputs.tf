output "instance_template_self_link" {
  value = google_compute_instance_template.template.self_link
}
output "instance_group_name" {
  value = google_compute_region_instance_group_manager.mig.name
}

