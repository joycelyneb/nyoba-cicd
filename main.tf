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

# 1. Ambil Resource Group (TechZone)
data "ibm_resource_group" "default" {
  name = var.resource_group
}

# 2. Buat Project Code Engine
resource "ibm_code_engine_project" "ce_project" {
  name              = var.project_name
  resource_group_id = data.ibm_resource_group.default.id
}

# 3. Simpan Rahasia Docker Hub (Agar IBM bisa tarik image)
resource "ibm_code_engine_secret" "registry_secret" {
  depends_on = [ibm_code_engine_project.ce_project]
  
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "dockerhub-secret"
  format     = "registry"
  
  data = {
    server   = "https://index.docker.io/v1/"
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
}

# 4. Simpan Env Vars Aplikasi
resource "ibm_code_engine_secret" "app_env_secret" {
  depends_on = [ibm_code_engine_project.ce_project]
  
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
  image_reference = "docker.io/${var.dockerhub_username}/backend-app:latest"
  image_port      = 5000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # SPEK HEMAT (Anti Error 502)
  scale_cpu_limit                = "0.25"
  scale_memory_limit             = "0.5G"
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
  image_reference = "docker.io/${var.dockerhub_username}/frontend-app:latest"
  image_port      = 3000
  image_secret    = ibm_code_engine_secret.registry_secret.name

  # SPEK HEMAT
  scale_cpu_limit                = "0.25"
  scale_memory_limit             = "0.5G"
  scale_ephemeral_storage_limit  = "400M"
  scale_min_instances            = 1
  scale_max_instances            = 1

  # Inject URL Backend
  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}