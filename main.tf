terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.56.0"
    }
    # 1. TAMBAHKAN PROVIDER TIME
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

# Resource Group
data "ibm_resource_group" "default" {
  name = var.resource_group
}

# Buat Project
resource "ibm_code_engine_project" "ce_project" {
  name              = var.project_name
  resource_group_id = data.ibm_resource_group.default.id
}

# 2. TAMBAHKAN TIMER (Jeda Waktu)
# Ini akan menahan proses selama 90 detik setelah Project jadi
resource "time_sleep" "wait_for_project_init" {
  depends_on = [ibm_code_engine_project.ce_project]

  create_duration = "90s" # Jeda 1.5 menit agar IBM Cloud stabil dulu
}

# Registry Secret (Kunci Masuk Docker Hub)
resource "ibm_code_engine_secret" "registry_secret" {
  # 3. UBAH DEPENDENCY: Jangan nunggu Project, tapi nunggu TIMER selesai
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

# App Environment Secret
resource "ibm_code_engine_secret" "app_env_secret" {
  # Nunggu timer juga
  depends_on = [time_sleep.wait_for_project_init]
  
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "app-env-secret"
  format     = "generic"
  
  data = {
    "NODE_ENV" = "production"
  }
}

# --- BACKEND ---
resource "ibm_code_engine_app" "backend" {
  # Backend nunggu Secret jadi (Secret nunggu Timer, Timer nunggu Project)
  # Jadi urutannya aman.
  depends_on      = [ibm_code_engine_secret.registry_secret]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-backend"
  image_reference = "docker.io/${var.dockerhub_username}/${var.backend_image}:latest"
  image_port      = 5000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # Spek Kecil (Aman)
  scale_cpu_limit                = "0.125"
  scale_memory_limit             = "0.25G"
  scale_ephemeral_storage_limit  = "400M"
  scale_min_instances            = 1
  scale_max_instances            = 1
  
  run_env_variables {
    type  = "literal"
    name  = "PORT"
    value = "5000"
  }
}

# --- FRONTEND ---
resource "ibm_code_engine_app" "frontend" {
  depends_on      = [ibm_code_engine_app.backend]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-frontend"
  image_reference = "docker.io/${var.dockerhub_username}/${var.frontend_image}:latest"
  image_port      = 3000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  scale_cpu_limit                = "0.125"
  scale_memory_limit             = "0.25G"
  scale_ephemeral_storage_limit  = "400M"
  scale_min_instances            = 1
  scale_max_instances            = 1

  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}