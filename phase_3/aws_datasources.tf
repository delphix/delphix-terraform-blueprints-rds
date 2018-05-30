data "terraform_remote_state" "delphix_infra" {
  backend = "local"
 
  config {
    path = "${path.module}/../phase_1/terraform.tfstate"
  }
}

data "terraform_remote_state" "delphix_objects" {
  backend = "local"
 
  config {
    path = "${path.module}/../phase_2/terraform.tfstate"
  }
}


data "aws_instance" "target" {
  instance_id = "${data.terraform_remote_state.delphix_infra.target_instance_id}"
}

# Specify the provider and access details
provider "aws" {
  region = "${data.terraform_remote_state.delphix_infra.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}
