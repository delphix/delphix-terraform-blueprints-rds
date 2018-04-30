resource "aws_vpc" "main" {
    cidr_block = "${var.cidr_block}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.project}_vpc"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
        UUID= "${random_id.rval.hex}"
    }
}

output "aws_vpc_id" {
  value = "${aws_vpc.main.id}"
}

resource "aws_route" "r"{
  route_table_id = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.main.id}"
}

resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "${var.project}_ig"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
        UUID= "${random_id.rval.hex}"
    }
}

resource "aws_subnet" "server_sub" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.server_network}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.project}_sub"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
        UUID= "${random_id.rval.hex}"
    }
}

output "aws_subnet_id" {
  value = "${aws_subnet.server_sub.id}"
}
