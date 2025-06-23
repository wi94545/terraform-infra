resource "google_compute_instance_template" "docker_nginx" {
  name         = "instance-template-docker-nginx-terraform"
  region       = "asia-east1"
  machine_type = "e2-medium"
  tags         = ["http-server", "https-server", "lb-health-check"]

  service_account {
    email  = "904029023371-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  disk {
    source_image = "cos-stable" # 自動產生的 COS 映像，Terraform 中直接指定 family 即可
    auto_delete  = true
    boot         = true
    type         = "pd-balanced"
    disk_size_gb = 30
  }

  network_interface {
    network    = "joe-vpc-1"
    subnetwork = "joe-test2"
    access_config {} # 無外部 IP：這樣配置會給一個 ephemeral IP，若要無外部 IP，請刪除這行
  }

  metadata = {
    gce-container-declaration = <<EOF
spec:
  containers:
    - name: custom-nginx
      image: asia-east1-docker.pkg.dev/silver-impulse-462505-s4/joe-repo/custom-nginx:latest
      stdin: false
      tty: false
  restartPolicy: Always
EOF
  }

  metadata_startup_script = "echo Hello from startup script"

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

  labels = {
    "container-vm" = "cos-stable"
  }

  lifecycle {
    create_before_destroy = true
  }
}

