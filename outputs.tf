output "project_id" {
  value = ibm_code_engine_project.ce_project.id
}

output "backend_url" {
  value = ibm_code_engine_app.backend.public_endpoint
}

output "frontend_url" {
  value = ibm_code_engine_app.frontend.public_endpoint
}
