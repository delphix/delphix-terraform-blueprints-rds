provider "delphix" {
  url = "http://${data.terraform_remote_state.delphix_infra.delphix_public_ip}"
  delphix_admin_username = "${var.delphix_admin_username}"
  delphix_admin_password = "${var.delphix_admin_password}"
}

resource "delphix_vdb" "devdb" {
  group_name = "Untitled"
  name = "Development Database"
  #description = "This is a copy of the RDS instance database to be used for development purposes"
  db_name = "devdb"
  source = "${data.terraform_remote_state.delphix_objects.rds-replica_id}"
  environment = "${data.terraform_remote_state.delphix_objects.environment_id}"
  oracle_home = "/u01/app/oracle/product/11.2.0.4/ora_1"
  mount_base = "/u01/app/toolkit"
  snap_source = true
}

output "Delphix DDP URL" {
  value = "http://${data.terraform_remote_state.delphix_infra.delphix_public_ip}"
}

output "Applications URL" {
  value = "http://${data.terraform_remote_state.delphix_infra.target_public_ip}"
}