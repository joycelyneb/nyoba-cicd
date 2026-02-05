terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.56.0"
    }
    # Provider tambahan untuk fitur "Jeda Waktu"
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

# 3. JEDA WAKTU (PENTING UNTUK MENCEGAH 502)
# Memberi waktu 60 detik agar Project benar-benar siap sebelum diisi
resource "time_sleep" "wait_for_project_init" {
  depends_on = [ibm_code_engine_project.ce_project]
  create_duration = "60s"
}

# 4. Registry Secret (Kunci Docker Hub)
resource "ibm_code_engine_secret" "registry_secret" {
  # Tunggu timer selesai dulu
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

# --- 6. BACKEND ---
resource "ibm_code_engine_app" "backend" {
  depends_on      = [ibm_code_engine_secret.registry_secret]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-backend"
  image_reference = "docker.io/${var.dockerhub_username}/${var.backend_image}:latest"
  image_port      = 5000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # SPEK MINIMUM (Paling Ringan)
  scale_cpu_limit                = "0.125"
  scale_memory_limit             = "0.25G"
  scale_ephemeral_storage_limit  = "400M"
  
  # SOLUSI UTAMA 502: Set ke 0 (Mati saat idle, nyala saat diklik)
  scale_min_instances            = 0
  scale_max_instances            = 1
  
  scale_concurrency              = 10
  scale_concurrency_target       = 10
  
  run_env_variables {
    type  = "literal"
    name  = "PORT"
    value = "5000"
  }
}

# --- 7. FRONTEND ---
resource "ibm_code_engine_app" "frontend" {
  # Tunggu backend selesai dibuat
  depends_on      = [ibm_code_engine_app.backend]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-frontend"
  image_reference = "docker.io/${var.dockerhub_username}/${var.frontend_image}:latest"
  image_port      = 3000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # SPEK MINIMUM
  scale_cpu_limit                = "0.125"
  scale_memory_limit             = "0.25G"
  scale_ephemeral_storage_limit  = "400M"
  
  # SOLUSI UTAMA 502: Set ke 0
  scale_min_instances            = 0
  scale_max_instances            = 1

  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}