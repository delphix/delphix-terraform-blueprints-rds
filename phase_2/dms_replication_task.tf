resource "aws_dms_replication_task" "dms" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = "${aws_dms_replication_instance.dms.replication_instance_arn}"
  replication_task_id       = "dms-replication-task-${data.terraform_remote_state.delphix_infra.uuid}"
  source_endpoint_arn       = "${aws_dms_endpoint.source.endpoint_arn}"
  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"DELPHIXDB\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
  replication_task_settings = "${trimspace(replace(replace(file("${path.module}/settings/replication_settings.json"), "/\\n\\s+/", ""),"/\\s+/", ""))}"

  tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_repl_task"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }

  target_endpoint_arn = "${aws_dms_endpoint.target.endpoint_arn}"
  
  #The below block is a workaround for issue: https://github.com/terraform-providers/terraform-provider-aws/issues/1513
  lifecycle {
	  ignore_changes = ["replication_task_settings"]
  }
}

output "replication_task_arn" {
  value = "${aws_dms_replication_task.dms.replication_task_arn}"
}