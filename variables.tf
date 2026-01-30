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
}

variable "backend_image" {
  type = string
}

variable "frontend_image" {
  type = string
}