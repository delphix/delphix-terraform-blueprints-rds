variable "access_key" {}
variable "secret_key" {}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS (do not include .pem extension)."
  default = "KEY_PAIR_NAME"
}

output "key_name" {
  value = "${var.key_name}"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default =  "us-west-2"
}

output "aws_region" {
  value = "${var.aws_region}"
}

variable "cidr_block" {
  description = "The network for the VPC"
  default = "10.0.0.0/16"
}

output "cidr_block" {
  value = "${var.cidr_block}"
}

variable "server_network" {
  description = "The network for the delphix engine and target host"
  default = "10.0.1.0/24"
}

output "server_network" {
  value = "${var.server_network}"
}

variable "owner" {
  description = "Tag to designate primary contact"
  default = "Placeholder Value"
}

output "owner" {
  value = "${var.owner}"
}

variable "expiration" {
  description = "Tag to designate when asset should be terminated"
  default = "2018-02-27"
}

output "expiration" {
  value = "${var.expiration}"
}

variable "project" {
  description = "Tag to designate affiliated project"
  default = "Placeholder Value"
}

output "project" {
  value = "${var.project}"
}

variable "rds_db_password" {
  description = "Password for the RDS database. Must contain 8 to 30 characters."
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