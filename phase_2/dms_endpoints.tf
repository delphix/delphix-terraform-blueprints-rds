resource "aws_dms_endpoint" "source" {
  depends_on                  = ["null_resource.emptydb"]
  database_name               = "${aws_db_instance.default.name}"
  endpoint_id                 = "source-${data.terraform_remote_state.delphix_infra.uuid}"
  endpoint_type               = "source"
  engine_name                 = "oracle"
  password                    = "${aws_db_instance.default.password}"
  port                        = "${aws_db_instance.default.port}"
  ssl_mode                    = "none"
  server_name                 = "${aws_db_instance.default.address}"
  extra_connection_attributes = "addSupplementalLogging=Y;readTableSpaceName=true"

  tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_aws_dms_endpoint_source"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }

  username = "${aws_db_instance.default.username}"
}

resource "aws_dms_endpoint" "target" {
  depends_on                  = ["delphix_vdb.rds-replica"]
  database_name               = "${delphix_vdb.rds-replica.db_name}"
  endpoint_id                 = "target-${data.terraform_remote_state.delphix_infra.uuid}"
  endpoint_type               = "target"
  engine_name                 = "oracle"
  password                    = "${delphix_data_source_oracle.my-dsource.password}"
  port                        = 1521
  ssl_mode                    = "none"
  server_name                 = "${aws_instance.target.public_dns}"

  tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_aws_dms_endpoint_target"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }

  username = "${delphix_data_source_oracle.my-dsource.user_name}"
}