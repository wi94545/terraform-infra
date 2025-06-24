# terraform-infra
# 🚀 Terraform GCP 執行個體範本 & 執行個體群組 模組化說明書

---

## 🗂 架構總覽

├── main.tf # 主要呼叫模組與設定參數
├── variables.tf # 變數定義 (project_id, region, zone, google_credentials)
├── provider.tf # GCP provider 設定
└── modules/
├── instance_template/ # 執行個體範本模組（Instance Template）
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
└── instance_group/ # 執行個體群組模組（Managed Instance Group）
├── main.tf
├── variables.tf
└── outputs.tf

yaml
---

## 1️⃣ 新增執行個體範本 (Instance Template)

### 🔧 操作步驟

1. 在 `main.tf` 裡新增範本模組呼叫：

```hcl
module "template_nginx" {
  source          = "./modules/instance_template"
  group_name      = "nginx"                                  # 群組名稱，會用於命名
  container_name  = "custom-nginx"                           # 容器名稱
  container_image = "asia-east1-docker.pkg.dev/your-project/your-repo/custom-nginx:1.0"  # 容器映像
  network         = "your-vpc-network"
  subnetwork      = "your-subnetwork"
  region          = var.region
}
執行 terraform apply，GCP 將建立該執行個體範本。

2️⃣ 新增執行個體群組 (Managed Instance Group)
🔧 操作步驟
在 main.tf 裡新增群組模組呼叫，並將剛剛範本的 self_link 傳入：

hcl
複製
編輯
module "group_nginx" {
  source           = "./modules/instance_group"
  group_name       = "nginx"
  region           = var.region
  instance_count   = 4
  min_replicas     = 4
  max_replicas     = 6
  instance_template = module.template_nginx.instance_template_self_link
}
執行 terraform apply，GCP 將依範本部署 VM 執行個體群組。

3️⃣ 新增另一組服務群組（範例：API 群組）
🔧 操作步驟
新增另一個執行個體範本模組呼叫：

module "template_api" {
  source          = "./modules/instance_template"
  group_name      = "api"
  container_name  = "custom-api"
  container_image = "asia-east1-docker.pkg.dev/your-project/your-repo/custom-api:1.0"
  network         = "your-vpc-network"
  subnetwork      = "your-subnetwork"
  region          = var.region
}
新增對應的執行個體群組模組呼叫：

module "group_api" {
  source           = "./modules/instance_group"
  group_name       = "api"
  region           = var.region
  instance_count   = 3
  min_replicas     = 2
  max_replicas     = 5
  instance_template = module.template_api.instance_template_self_link
}
執行 terraform apply，新增多組獨立服務群組。

4️⃣ 更新容器映像（Container Image）
修改呼叫 instance_template 模組中的 container_image 參數：

container_image = "asia-east1-docker.pkg.dev/your-project/your-repo/custom-nginx:2.0"
執行 terraform apply，Terraform 會更新範本並自動滾動更新群組。

⚠️ 注意事項
🔐 Service Account 權限
請確認範本中指定的 Service Account 擁有讀取 Artifact Registry 映像與 Compute Engine 權限。

🌏 Region 與 Zone
建議以 region 管理資源，避免混用 zone，減少管理複雜度。

⚙️ 模組參數
請根據實際需求調整 instance_count、min_replicas、max_replicas 等參數。

📤 Outputs 使用
可使用模組 outputs 取得關鍵資源資訊，如範本 self_link 等：

output "instance_template_self_link" {
  value = google_compute_instance_template.template.self_link
}
