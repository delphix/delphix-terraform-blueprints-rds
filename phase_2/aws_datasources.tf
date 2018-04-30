data "terraform_remote_state" "delphix_infra" {
  backend = "local"
 
  config {
    path = "${path.module}/../phase_1/terraform.tfstate"
  }
}

# Specify the provider and access details
provider "aws" {
  region = "${data.terraform_remote_state.delphix_infra.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_ami" "OL69" {
  #Grab the latest version of CentOS 6 with Oracle 11.2.0.4
  most_recent = true
  owners = ["self"]
  #Grab the latest version of CentOS 6 with Oracle 11.2.0.4
  filter {
    name = "name"
    values = ["CentOS6.9 Oracle 11.2.0.4"]
  }
}
