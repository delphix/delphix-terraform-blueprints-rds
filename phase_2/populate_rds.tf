resource "null_resource" "copy_populate_rds_db" {
    connection {
        host = "${data.aws_instance.target.public_ip}"
        type     = "ssh"
        user     = "oracle"
        private_key = "${file("../${data.terraform_remote_state.delphix_infra.key_name}.pem")}"
        timeout = "15s"
    }
  
  provisioner "file" {
    source      = "scripts/populate_rds"
    destination = "/home/oracle/"
  }
}

resource "null_resource" "populate_rds_db" {
    depends_on = ["null_resource.copy_populate_rds_db"]
    connection {
        host = "${data.aws_instance.target.public_ip}"
        type     = "ssh"
        user     = "oracle"
        private_key = "${file("../${data.terraform_remote_state.delphix_infra.key_name}.pem")}"
        timeout = "15s"
    }
  
  provisioner "file" {
    source      = "scripts/populate_rds/populate_rds_db.sh"
    destination = "/home/oracle/populate_rds/populate_rds_db.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/oracle/populate_rds/populate_rds_db.sh",
      "/home/oracle/populate_rds/populate_rds_db.sh ${data.aws_db_instance.default.address} EMPTY ${var.rds_db_password}",
    ]
  }
}