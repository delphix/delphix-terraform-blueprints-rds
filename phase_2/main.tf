
resource "aws_instance" "target" {
  ami = "${data.aws_ami.OL69.id}"
  instance_type = "t2.large"
  key_name = "${data.terraform_remote_state.delphix_infra.key_name}"
  connection {
    type = "ssh"
    user = "centos"
    private_key = "${file("${data.terraform_remote_state.delphix_infra.key_name}.pem")}"
    timeout = "3m"
  }
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${data.terraform_remote_state.delphix_infra.aws_security_group_id}"]

  subnet_id = "${data.terraform_remote_state.delphix_infra.aws_subnet_id}"
 
  #call the user_data template
  user_data = "${data.template_file.user_data_shell.rendered}"
  
  #We just use this to loop until we know our server is ready
  provisioner "remote-exec" {
        inline = [
        "echo hello world",
        ]
   }

  #Instance tags
  tags {
    Name = "${data.terraform_remote_state.delphix_infra.project}_oel"
    UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
    "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
    "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
    "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
  }
}

output "target_public_ip" {
  value = "${aws_instance.target.public_ip}"
}

output "target_private_ip" {
  value = "${aws_instance.target.private_ip}"
}

#Add our public SSH key to the delphix user so that we can log in directly
data "template_file" "user_data_shell" {
  template = <<-EOF
    #!/bin/bash
    yum install -y bind-utils
    curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /home/delphix/.ssh/authorized_keys
    #Hard-coded Delphix Engine Key
    echo "${var.delphix_engine_system_key}" >> /home/delphix/.ssh/authorized_keys
    mkdir /home/oracle/.ssh
    curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /home/oracle/.ssh/authorized_keys
    chown -R oracle.oinstall /home/oracle/.ssh
    chmod 700 /home/oracle/.ssh
    chmod 600 /home/oracle/.ssh/authorized_keys
    EOF
}

resource "null_resource" "emptydb" {
    connection {
        host = "${aws_instance.target.public_ip}"
        type     = "ssh"
        user     = "oracle"
        private_key = "${file("${data.terraform_remote_state.delphix_infra.key_name}.pem")}"
        timeout = "15s"
    }

  provisioner "file" {
    source      = "scripts/emptydb"
    destination = "/home/oracle/emptydb"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod -R +x /home/oracle/emptydb",
      "/home/oracle/emptydb/EMPTY.sh ${var.delphixdb_password}",
    ]
  }
}

