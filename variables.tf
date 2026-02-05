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
  default = "nyoba-cicd-joy2"
}

variable "dockerhub_username" {
  type    = string
  default = "joycelyneb"
}

variable "dockerhub_password" {
  type      = string
  sensitive = true
}

# Image Reference otomatis dibentuk dari username
variable "backend_image" {
  type    = string
  default = "backend-app"
}

variable "frontend_image" {
  type    = string
  default = "frontend-app"
}