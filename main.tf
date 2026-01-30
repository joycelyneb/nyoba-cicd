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

# 1. Ambil data Resource Group
data "ibm_resource_group" "default" {
  name = var.resource_group
}

# 2. BUAT NAMESPACE
resource "ibm_cr_namespace" "registry_namespace" {
  name              = "nyoba-cicd"
  resource_group_id = data.ibm_resource_group.default.id
}

# 3. Buat Project Code Engine
resource "ibm_code_engine_project" "ce_project" {
  name              = var.project_name
  resource_group_id = data.ibm_resource_group.default.id
}

# --- BACKEND ---
resource "ibm_code_engine_app" "backend" {
  # Backend harus nunggu Project DAN Namespace jadi dulu
  depends_on      = [ibm_code_engine_project.ce_project, ibm_cr_namespace.registry_namespace]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-backend"
  image_reference = var.backend_image
  image_port      = 5000

  run_env_variables {
    type  = "literal"
    name  = "PORT"
    value = "5000"
  }
}

# --- FRONTEND ---
resource "ibm_code_engine_app" "frontend" {
  # Frontend nunggu Backend jadi dulu (untuk dapet URL endpoint)
  depends_on      = [ibm_code_engine_app.backend]
  
  project_id      = ibm_code_engine_project.ce_project.project_id
  name            = "${var.project_name}-frontend"
  image_reference = var.frontend_image
  image_port      = 3000

  run_env_variables {
    type  = "literal"
    name  = "REACT_APP_BACKEND_URL"
    value = ibm_code_engine_app.backend.endpoint 
  }
}