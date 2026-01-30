output "project_id" {
  value = ibm_code_engine_project.ce_project.project_id
}

output "backend_url" {
  value = ibm_code_engine_app.backend.endpoint
}

output "frontend_url" {
  value = ibm_code_engine_app.frontend.endpoint
}