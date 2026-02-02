variable "ibmcloud_api_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "us-south"
}

variable "resource_group" {
  type        = string
  description = "Nama Resource Group dari TechZone"
  default     = "itz-wxo-697c4652010cfefe9db664" 
}

variable "project_name" {
  type    = string
  default = "nyoba-cicd-joy"
}

variable "backend_image" {
  type    = string
  default = "icr.io/cr-itz-z3r4x650/backend-app:latest"
}

variable "frontend_image" {
  type    = string
  default = "icr.io/cr-itz-z3r4x650/frontend-app:latest"
}