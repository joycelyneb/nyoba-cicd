terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.56.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# 1. Ambil Data Resource Group
data "ibm_resource_group" "default" {
  name = var.resource_group
}

# 2. Buat Project Code Engine
resource "ibm_code_engine_project" "ce_project" {
  name              = var.project_name
  resource_group_id = data.ibm_resource_group.default.id
}

# 3. JEDA WAKTU (PENTING UNTUK STABILISASI PROJECT)
resource "time_sleep" "wait_for_project_init" {
  depends_on = [ibm_code_engine_project.ce_project]
  create_duration = "60s"
}

# 4. Registry Secret (Kunci Docker Hub)
resource "ibm_code_engine_secret" "registry_secret" {
  depends_on = [time_sleep.wait_for_project_init]
  
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "dockerhub-secret"
  format     = "registry"
  
  data = {
    server   = "https://index.docker.io/v1/"
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
}

# 5. App Env Secret
resource "ibm_code_engine_secret" "app_env_secret" {
  depends_on = [time_sleep.wait_for_project_init]
  
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "app-env-secret"
  format     = "generic"
  
  data = {
    "NODE_ENV" = "production"
  }
}

# --- 6. BACKEND (SPEK STANDAR) ---
resource "ibm_code_engine_app" "backend" {
  depends_on      = [ibm_code_engine_secret.registry_secret]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-backend"
  image_reference = "docker.io/${var.dockerhub_username}/${var.backend_image}:latest"
  image_port      = 5000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # --- SPEK YANG LEBIH KUAT (Bukan Minimum) ---
  scale_cpu_limit                = "0.5"   # Naik dari 0.125
  scale_memory_limit             = "1G"    # Naik dari 0.25G
  scale_ephemeral_storage_limit  = "1G"    # Cukup luas

  # TETAP 0 SAAT CREATE AGAR TIDAK ERROR 502
  scale_min_instances            = 0
  scale_max_instances            = 5       # Bisa nambah sampai 5 kalau ramai
  
  scale_concurrency              = 100
  scale_concurrency_target       = 80
  
  run_env_variables {
    type  = "literal"
    name  = "PORT"
    value = "5000"
  }
}

# --- 7. FRONTEND (SPEK STANDAR) ---
resource "ibm_code_engine_app" "frontend" {
  depends_on      = [ibm_code_engine_app.backend]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-frontend"
  image_reference = "docker.io/${var.dockerhub_username}/${var.frontend_image}:latest"
  image_port      = 3000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # --- SPEK YANG LEBIH KUAT ---
  scale_cpu_limit                = "0.5"
  scale_memory_limit             = "1G"
  scale_ephemeral_storage_limit  = "1G"
  
  scale_min_instances            = 0
  scale_max_instances            = 5

  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}