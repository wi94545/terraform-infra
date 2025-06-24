output "instance_template_self_link" {
  value = var.instance_template
}
output "instance_group_name" {
  value = google_compute_region_instance_group_manager.mig.name
}

