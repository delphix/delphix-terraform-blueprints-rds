provider "delphix" {
  url = "http://${data.terraform_remote_state.delphix_infra.delphix_public_ip}"
  delphix_admin_username = "${var.delphix_admin_username}"
  delphix_admin_password = "${var.delphix_admin_password}"
}

resource "delphix_environment" "my-environment" {
  depends_on = ["aws_instance.target", "null_resource.emptydb"]
  name = "LINUXTARGET"
  description = "Provisioned via Terraform"
  address = "${aws_instance.target.private_ip}"
  user_name = "delphix"
  public_key = true
  toolkit_path = "/u01/app/toolkit"
  server_id = "${aws_instance.target.id}"
}

resource "delphix_data_source_oracle" "my-dsource" {
  depends_on = ["null_resource.emptydb"]
  name = "Empty Database"
  description = "Provisioned via Terraform"
  user_name = "delphixdb"
  password = "${var.delphixdb_password}"
  group_name = "Untitled"
  environment = "${delphix_environment.my-environment.id}"
  environment_user = "delphix"
  link_now = true
  instance = "EMPTY"
  oracle_home = "/u01/app/oracle/product/11.2.0.4/ora_1"

}

resource "delphix_vdb" "rds-replica" {
  group_name = "Untitled"
  name = "RDS Replica VDB"
  db_name = "rdsrepl"
  source = "${delphix_data_source_oracle.my-dsource.id}"
  environment = "${delphix_environment.my-environment.id}"
  oracle_home = "/u01/app/oracle/product/11.2.0.4/ora_1"
  mount_base = "/u01/app/toolkit"
}

resource "null_resource" "copy_populate_rds_db" {
    depends_on = ["aws_instance.target","aws_db_instance.default"]
    connection {
        host = "${aws_instance.target.public_ip}"
        type     = "ssh"
        user     = "oracle"
        private_key = "${file("${data.terraform_remote_state.delphix_infra.key_name}.pem")}"
        timeout = "15s"
    }
  
  provisioner "file" {
    source      = "scripts/populate_rds"
    destination = "/home/oracle/"
  }
}

resource "null_resource" "populate_rds_db" {
    depends_on = ["null_resource.copy_populate_rds_db","delphix_vdb.rds-replica"]
    connection {
        host = "${aws_instance.target.public_ip}"
        type     = "ssh"
        user     = "oracle"
        private_key = "${file("${data.terraform_remote_state.delphix_infra.key_name}.pem")}"
        timeout = "15s"
    }
  
  provisioner "file" {
    source      = "scripts/populate_rds/populate_rds_db.sh"
    destination = "/home/oracle/populate_rds/populate_rds_db.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/oracle/populate_rds/populate_rds_db.sh",
      "/home/oracle/populate_rds/populate_rds_db.sh ${aws_db_instance.default.address} ${delphix_vdb.rds-replica.db_name} ${var.rds_db_password}",
    ]
  }
}

resource "null_resource" "delete-emptydb" {
  depends_on = ["delphix_data_source_oracle.my-dsource"]
  connection {
        host = "${aws_instance.target.public_ip}"
        type     = "ssh"
        user     = "oracle"
        private_key = "${file("${data.terraform_remote_state.delphix_infra.key_name}.pem")}"
        timeout = "15s"
    }

  provisioner "remote-exec" {
    inline = [
      "/home/oracle/emptydb/delete_empty.sh",
    ]
  }
}
