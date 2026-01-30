variable "ibmcloud_api_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "us-south"
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