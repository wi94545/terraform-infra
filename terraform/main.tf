# 變數定義
variable "google_credentials" {
  description = "Base64 encoded GCP service account JSON"
  type        = string
  sensitive   = true
}

variable "project_id" {
  default = "silver-impulse-462505-s4"
}

variable "region" {
  default = "asia-east1"
}

variable "zone" {
  default = "asia-east1-c"
}

# Provider 設定
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = base64decode(var.google_credentials)
}

# 呼叫 instance_template 模組
module "template_nginx" {
  source          = "./modules/instance_template"
  group_name      = "nginx"
  container_name  = "custom-nginx"
  container_image = "asia-east1-docker.pkg.dev/silver-impulse-462505-s4/joe-repo/custom-nginx:latest"
  network         = "joe-vpc-1"
  subnetwork      = "joe-test2"
  region          = var.region
  zone            = var.zone
}

# 呼叫 instance_group 模組
module "group_nginx" {
  source           = "./modules/instance_group"
  group_name       = "nginx"
  region           = var.region
  instance_count   = 4
  min_replicas     = 4
  max_replicas     = 6
  instance_template = module.template_nginx.instance_template_self_link
}

