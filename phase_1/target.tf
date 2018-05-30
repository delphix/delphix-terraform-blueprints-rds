
data "aws_ami" "delphix-ready-ami" {
  #Grab the ami created by <insert url here>
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["delphix-rds-demo-target"]
  }
}

resource "aws_instance" "target" {
  ami = "${data.aws_ami.delphix-ready-ami.id}"
  instance_type = "t2.large"
  key_name = "${var.key_name}"
  connection {
    type = "ssh"
    user = "centos"
    private_key = "${file("${path.module}/../${var.key_name}.pem")}"
    timeout = "3m"
  }
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]

  subnet_id = "${aws_subnet.server_sub.id}"
 
  #call the user_data template
  user_data = "${data.template_file.user_data_shell.rendered}"
  
  #We just use this to loop until we know our server is ready
  provisioner "remote-exec" {
        inline = [
         "until sudo su - oracle -c \"lsnrctl status | grep EMPTY| grep 'status READY'\"; do echo waiting for listener to start; sleep 3; done",
         "sudo /home/centos/delphix-engine-configurator -hostname ${aws_instance.de.private_ip} -syspass sysadmin -dapass ${var.delphix_admin_password} -filename /home/delphix/.ssh/authorized_keys | tee /tmp/key.log",
        ]
   }

  #Instance tags
  tags {
    Name = "${var.project}_oel"
    UUID= "${random_id.rval.hex}"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
  }
}

output "target_public_ip" {
  value = "${aws_instance.target.public_ip}"
}

output "target_instance_id" {
  value = "${aws_instance.target.id}"
}

output "target_private_ip" {
  value = "${aws_instance.target.private_ip}"
}

#Add our public SSH key to the delphix user so that we can log in directly
data "template_file" "user_data_shell" {
  template = <<-EOF
    #!/bin/bash
    mkdir /home/oracle/.ssh
    echo "`dig +short ${aws_db_instance.default.address}`  rdshost ${aws_db_instance.default.address}" >> /etc/hosts
    curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /home/oracle/.ssh/authorized_keys
    chown -R oracle.oinstall /home/oracle/.ssh
    chmod 700 /home/oracle/.ssh
    chmod 600 /home/oracle/.ssh/authorized_keys
    EOF
}

