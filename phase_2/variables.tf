variable "access_key" {}
variable "secret_key" {}

variable "rds_db_password" {
  description = "Password for the RDS database. Must contain 8 to 30 characters."
}

variable "delphixdb_password" {
  description = "Password for the delphixdb database user."
}

variable "delphix_admin_username" {
  description = "The delphix admin used to connect"
  default = "delphix_admin"
}

variable "delphix_admin_password" {
  description = "The password for the delphix_admin_username"
}
