terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.56.0"
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

# Registry Secret (Kunci Masuk Docker Hub)
resource "ibm_code_engine_secret" "registry_secret" {
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "dockerhub-secret"
  format     = "registry"
  
  data = {
    server   = "https://index.docker.io/v1/" # Server resmi Docker Hub
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
}

# App Environment Secret (Untuk Env Vars Rahasia)
resource "ibm_code_engine_secret" "app_env_secret" {
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "app-env-secret"
  format     = "generic"
  
  data = {
    "NODE_ENV" = "production"
  }
}

# --- BACKEND ---
resource "ibm_code_engine_app" "backend" {
  depends_on      = [ibm_code_engine_secret.registry_secret]
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-backend"
  
  # Image otomatis: joycelyneb/backend-app:latest
  image_reference = "docker.io/${var.dockerhub_username}/${var.backend_image}:latest"
  image_port      = 5000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  scale_cpu_limit                = "0.25"
  scale_memory_limit             = "0.5G"
  scale_ephemeral_storage_limit  = "400M" # Perkecil juga storage-nya
  scale_min_instances            = 1
  scale_max_instances            = 2      # Jangan banyak-banyak dulu
  scale_concurrency              = 10
  scale_concurrency_target       = 10
  
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
  
  # Image otomatis: joycelyneb/frontend-app:latest
  image_reference = "docker.io/${var.dockerhub_username}/${var.frontend_image}:latest"
  image_port      = 3000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  scale_cpu_limit                = "0.25"
  scale_memory_limit             = "0.5G"
  scale_ephemeral_storage_limit  = "400M"
  scale_min_instances            = 1
  scale_max_instances            = 2

  # Menyambungkan URL Backend ke Frontend
  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}