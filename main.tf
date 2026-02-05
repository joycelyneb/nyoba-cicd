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

# Resource Group
data "ibm_resource_group" "default" {
  name = var.resource_group
}

# 2. BUAT PROJECT
resource "ibm_code_engine_project" "ce_project" {
  name              = var.project_name
  resource_group_id = data.ibm_resource_group.default.id
}

# 3. WAIT FOR PROJECT INITIALIZATION
resource "time_sleep" "wait_for_project_init" {
  depends_on = [
    ibm_code_engine_secret.app_env_secret,
    ibm_code_engine_secret.registry_secret
  ]
  create_duration = "120s"
}

# 4. Registry Secret (Kunci Docker Hub)
resource "ibm_code_engine_secret" "registry_secret" {
  # Tunggu timer selesai dulu (bukan langsung project)
  depends_on = [time_sleep.wait_for_project_init]
  
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "dockerhub-secret"
  format     = "registry"
  
  data = {
    server   = "docker.io"
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
}

# App Environment Secret
resource "ibm_code_engine_secret" "app_env_secret" {
  depends_on = [time_sleep.wait_for_project_init]
  
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "app-env-secret"
  format     = "generic"
  
  data = {
    "NODE_ENV" = "production"
  }
}

# --- 5. BACKEND (SPEK TINGGI - KEMBALI SEPERTI SEMULA) ---
resource "ibm_code_engine_app" "backend" {
  depends_on      = [time_sleep.wait_for_project_init, ibm_code_engine_secret.registry_secret]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-backend"
  image_reference = var.backend_image
  image_port      = 5000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # SPEK TINGGI (Sesuai request kamu)
  scale_cpu_limit                = "2"
  scale_memory_limit             = "4G"
  scale_ephemeral_storage_limit  = "2457M"
  
  # Tetap Min 1 (Langsung Nyala)
  scale_min_instances            = 1
  scale_max_instances            = 10
  scale_concurrency              = 10
  scale_concurrency_target       = 10
  
  run_env_variables {
    type  = "literal"
    name  = "PORT"
    value = "5000"
  }
}

# --- 6. FRONTEND (SPEK TINGGI) ---
resource "ibm_code_engine_app" "frontend" {
  depends_on      = [ibm_code_engine_app.backend]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-frontend"
  image_reference = var.frontend_image
  image_port      = 3000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # SPEK TINGGI
  scale_cpu_limit                = "2"
  scale_memory_limit             = "4G"
  scale_ephemeral_storage_limit  = "2457M"
  
  scale_min_instances            = 1
  scale_max_instances            = 10
  scale_concurrency              = 10
  scale_concurrency_target       = 10

  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}