resource "aws_subnet" "database1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.database_networks[0]}"
    availability_zone = "${var.database_azs[0]}"
    map_public_ip_on_launch = false

    tags {
        Name = "${var.project}_sub_database1"
        UUID= "${random_id.rval.hex}"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
    }
}

output "database1_id" {
  value = "${aws_subnet.database1.id}"
}

resource "aws_subnet" "database2" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.database_networks[1]}"
    availability_zone = "${var.database_azs[1]}"
    map_public_ip_on_launch = false

    tags {
        Name = "${var.project}_sub_database2"
        UUID= "${random_id.rval.hex}"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
    }
}

output "database2_id" {
  value = "${aws_subnet.database2.id}"
}

resource "aws_db_subnet_group" "default" {
  subnet_ids = ["${aws_subnet.database1.id}", "${aws_subnet.database2.id}"]

  tags {
        Name = "${var.project}_database_subnet_group"
        UUID= "${random_id.rval.hex}"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
    }
}

output "aws_db_subnet_group_id" {
  value = "${aws_db_subnet_group.default.id}"
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
  auto_minor_version_upgrade = false
  username             = "delphixdb"
  password             = "${var.rds_db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  skip_final_snapshot = true
  tags {
        Name = "${var.project}_aws_db_instance"
        UUID= "${random_id.rval.hex}"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
    }
}

output "aws_db_instance_id" {
  value = "${aws_db_instance.default.id}"
}

output "rds_address" {
  value = "${aws_db_instance.default.address}"
}