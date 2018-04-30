resource "aws_subnet" "database1" {
    vpc_id = "${data.terraform_remote_state.delphix_infra.aws_vpc_id}"
    cidr_block = "${var.database_networks[0]}"
    availability_zone = "${var.database_azs[0]}"
    map_public_ip_on_launch = false

    tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_sub_database1"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }
}

resource "aws_subnet" "database2" {
    vpc_id = "${data.terraform_remote_state.delphix_infra.aws_vpc_id}"
    cidr_block = "${var.database_networks[1]}"
    availability_zone = "${var.database_azs[1]}"
    map_public_ip_on_launch = false

    tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_sub_database2"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }
}

resource "aws_db_subnet_group" "default" {
  name       = "database_subnet_group"
  subnet_ids = ["${aws_subnet.database1.id}", "${aws_subnet.database2.id}"]

  tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_database_subnet_group"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }
}

resource "aws_db_instance" "default" {
  apply_immediately = true
  backup_retention_period = 2
  port = 1521
  copy_tags_to_snapshot = true
  storage_type         = "gp2"
  instance_class       = "db.t2.micro"
  allocated_storage    = 20
  engine               = "oracle-ee"
  engine_version       = "11.2.0.4.v15"
  username             = "delphixdb"
  password             = "${var.rds_db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  vpc_security_group_ids = ["${data.terraform_remote_state.delphix_infra.aws_security_group_id}"]
  skip_final_snapshot = true
  tags {
        Name = "${data.terraform_remote_state.delphix_infra.project}_aws_db_instance"
        UUID= "${data.terraform_remote_state.delphix_infra.uuid}"
        "dlpx:Project" = "${data.terraform_remote_state.delphix_infra.project}"
        "dlpx:Owner" = "${data.terraform_remote_state.delphix_infra.owner}"
        "dlpx:Expiration" = "${data.terraform_remote_state.delphix_infra.expiration}"
    }
}

output "rds_address" {
  value = "${aws_db_instance.default.address}"
}