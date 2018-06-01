resource "aws_dms_replication_subnet_group" "dms" {
  replication_subnet_group_description = "DMS Replication Subnet Group"
  replication_subnet_group_id          = "dmssg-${data.terraform_remote_state.delphix_infra.uuid}"
  subnet_ids = ["${data.terraform_remote_state.delphix_infra.database1_id}", "${data.terraform_remote_state.delphix_infra.database2_id}"]
}

resource "aws_dms_replication_instance" "dms" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = false
  availability_zone            = "${data.aws_db_instance.default.availability_zone}"
  multi_az                     = false
  publicly_accessible          = false
  replication_instance_class   = "dms.t2.large"
  replication_instance_id      = "dms-replication-instance-${data.terraform_remote_state.delphix_infra.uuid}"
  replication_subnet_group_id  = "${aws_dms_replication_subnet_group.dms.id}"

  tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_aws_dms_replication_instance"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }

  vpc_security_group_ids = ["${data.terraform_remote_state.delphix_infra.aws_security_group_id}"]
}

output "dms_replication_instance_private_ip" {
  value = "${aws_dms_replication_instance.dms.replication_instance_private_ips.0}"
}