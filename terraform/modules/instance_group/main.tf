resource "google_compute_health_check" "hc" {
  name = "health-check-${var.group_name}"

  tcp_health_check {
    port = 80
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  unhealthy_threshold = 5
  healthy_threshold   = 2
}

resource "google_compute_region_instance_group_manager" "mig" {
  name               = "instance-group-${var.group_name}"
  region             = var.region
  base_instance_name = "${var.group_name}-vm"

  version {
    instance_template = var.instance_template
  }

  target_size = var.instance_count

  auto_healing_policies {
    health_check      = google_compute_health_check.hc.self_link
    initial_delay_sec = 300
  }

  named_port {
    name = "http"
    port = 80
  }

  update_strategy = "ROLLING_UPDATE"

  rolling_update_policy {
    max_surge       = 1
    max_unavailable = 0
  }
}

resource "google_compute_autoscaler" "as" {
  name   = "autoscaler-${var.group_name}"
  region = var.region
  target = google_compute_region_instance_group_manager.mig.self_link

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}
