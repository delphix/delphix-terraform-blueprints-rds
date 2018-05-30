provider "delphix" {
  url = "http://${data.terraform_remote_state.delphix_infra.delphix_public_ip}"
  delphix_admin_username = "${var.delphix_admin_username}"
  delphix_admin_password = "${var.delphix_admin_password}"
}

resource "delphix_environment" "my-environment" {
  // depends_on = ["aws_instance.target", "null_resource.emptydb"]
  name = "LINUXTARGET"
  description = "Provisioned via Terraform"
  address = "${data.aws_instance.target.private_ip}"
  user_name = "delphix"
  public_key = true
  toolkit_path = "/u01/app/toolkit"
  server_id = "${data.aws_instance.target.id}"
}

resource "delphix_data_source_oracle" "my-dsource" {
  depends_on = ["null_resource.copy_populate_rds_db"]
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
  #description = "This only recieves updates from the RDS instance"
  db_name = "rdsrepl"
  source = "${delphix_data_source_oracle.my-dsource.id}"
  environment = "${delphix_environment.my-environment.id}"
  oracle_home = "/u01/app/oracle/product/11.2.0.4/ora_1"
  mount_base = "/u01/app/toolkit"
}

output "environment_id" {
  value = "${delphix_environment.my-environment.id}"
}
output "rds-replica_id" {
  value = "${delphix_vdb.rds-replica.id}"
}

output "delphix_public_ip" {
  value = "${data.terraform_remote_state.delphix_infra.delphix_public_ip}"
}