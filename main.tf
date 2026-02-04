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

# Registry Secret for Docker Hub
resource "ibm_code_engine_secret" "registry_secret" {
  depends_on = [ibm_code_engine_project.ce_project]
  
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
  depends_on = [ibm_code_engine_project.ce_project]
  
  project_id = ibm_code_engine_project.ce_project.project_id
  name       = "app-env-secret"
  format     = "generic"
  
  data = {
    "EXAMPLE_KEY" = "example_value"
  }
}

# --- BACKEND ---
resource "ibm_code_engine_app" "backend" {
  depends_on = [ibm_code_engine_project.ce_project]
  
  project_id             = ibm_code_engine_project.ce_project.project_id
  name                   = "${var.project_name}-backend"
  image_reference        = "docker.io/${var.dockerhub_username}/backend-app:latest"
  image_port             = 5000
  image_secret           = ibm_code_engine_secret.registry_secret.name

  scale_cpu_limit               = "2"
  scale_memory_limit             = "4G"
  scale_ephemeral_storage_limit  = "2457M"
  scale_min_instances            = 1
  scale_max_instances            = 10
  scale_concurrency              = 10
  scale_concurrency_target       = 10

  run_env_variables {
    type      = "secret_full_reference"
    reference = ibm_code_engine_secret.app_env_secret.name
  }
}

# --- FRONTEND ---
resource "ibm_code_engine_app" "frontend" {
  depends_on = [ibm_code_engine_app.backend]
  
  project_id             = ibm_code_engine_project.ce_project.project_id
  name                   = "${var.project_name}-frontend"
  image_reference        = "docker.io/${var.dockerhub_username}/frontend-app:latest"
  image_port             = 3000
  image_secret           = ibm_code_engine_secret.registry_secret.name

  scale_cpu_limit               = "2"
  scale_memory_limit             = "4G"
  scale_ephemeral_storage_limit  = "2457M"
  scale_min_instances            = 1
  scale_max_instances            = 10
  scale_concurrency              = 10
  scale_concurrency_target       = 10

  run_env_variables {
    type      = "secret_full_reference"
    reference = ibm_code_engine_secret.app_env_secret.name
  }

  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}