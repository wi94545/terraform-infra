resource "google_compute_instance_template" "template" {
  name         = "instance-template-${var.group_name}"
  machine_type = "e2-medium"
  tags         = ["http-server", "https-server", "lb-health-check"]

  disk {
    source_image = "projects/cos-cloud/global/images/cos-stable-121-18867-90-62"
    auto_delete  = true
    boot         = true
    type         = "pd-balanced"
    disk_size_gb = 30
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    # access_config {} 臨時外網ＩＰ
  }

  metadata = {
    gce-container-declaration = <<EOF
spec:
  containers:
    - name: ${var.container_name}
      image: ${var.container_image}
      stdin: false
      tty: false
  restartPolicy: Always
EOF
  }

  # Service Account
  service_account {
    email  = "904029023371-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
