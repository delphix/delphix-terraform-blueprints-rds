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