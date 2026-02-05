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

variable "dockerhub_username" {
  type    = string
  default = "joycelyneb"
}

variable "dockerhub_password" {
  type      = string
  sensitive = true
  # TOKEN JANGAN DITULIS DISINI! Nanti diambil dari GitHub Secrets.
}

# Image Reference otomatis dibentuk dari username
variable "backend_image" {
  type    = string
  default = "backend-app" # Cukup nama aplikasinya aja
}

variable "frontend_image" {
  type    = string
  default = "frontend-app" # Cukup nama aplikasinya aja
}