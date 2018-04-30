# Generate random ID (used for tagging devices)
resource "random_id" "rval" {
  byte_length = 8
}

output "uuid" {
  value = "${random_id.rval.hex}"
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_ami" "de_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["Delphix Engine 5.2.4*"]
  }

  #From Delphix
  owners = ["180093685553"]
}

resource "aws_instance" "de" {
  instance_type = "t2.medium"
  # Lookup the correct AMI based on the region
  # we specified
  ami = "${data.aws_ami.de_ami.id}"

  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]

  subnet_id = "${aws_subnet.server_sub.id}"
  
  ebs_block_device {
        device_name = "/dev/sdb"
        volume_type = "gp2"
        volume_size = "2"
        delete_on_termination = true

    }
  ebs_block_device {
        device_name = "/dev/sdc"
        volume_type = "gp2"
        volume_size = "2"
        delete_on_termination = true

    }
  ebs_block_device {
        device_name = "/dev/sdd"
        volume_type = "gp2"
        volume_size = "2"
        delete_on_termination = true

    }
  #Instance tags
  tags {
    Name = "${var.project}_DE"
    UUID= "${random_id.rval.hex}"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
  }
}

output "delphix_public_ip" {
  value = "${aws_instance.de.public_ip}"
}

output "delphix_private_ip" {
  value = "${aws_instance.de.private_ip}"
}
