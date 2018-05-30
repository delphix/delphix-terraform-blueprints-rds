variable "access_key" {}
variable "secret_key" {}

variable "delphix_admin_username" {
  description = "The delphix admin used to connect"
  default = "delphix_admin"
}

variable "delphix_admin_password" {
  description = "The password for the delphix_admin_username"
}
