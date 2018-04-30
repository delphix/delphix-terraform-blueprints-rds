variable "access_key" {}
variable "secret_key" {}

variable "rds_db_password" {
  description = "Password for the RDS database. Must contain 8 to 30 characters."
}

variable "delphixdb_password" {
  description = "Password for the delphixdb database user."
}

variable "database_networks" {
  description = "RDS and DMS require two dedicated networks."
  default = ["10.0.2.0/24","10.0.3.0/24"]
}

variable "database_azs" {
  description = "RDS requires two different availability zones in the region."
  default = ["us-west-2a","us-west-2b"]
}

output "database_networks" {
  value = "${var.database_networks}"
}

variable "delphix_admin_username" {
  description = "The delphix admin used to connect"
  default = "delphix_admin"
}

variable "delphix_admin_password" {
  description = "The password for the delphix_admin_username"
}

variable "delphix_engine_system_key" {
  description = "The public key Delphix will use to connect to the host environments"
}