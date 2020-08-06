variable "app_name" {
  type    = string
  default = "node-app"
}

variable "internal_port" {
  type    = string
  default = "3000"
}

variable "external_port" {
  type    = string
  default = "8081"
}

variable "dockerhub_repo" {
  type    = string
  default = "sergeymatsak"
}