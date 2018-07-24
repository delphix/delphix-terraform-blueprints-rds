data "http" "your_ip" {
  url = "http://ipv4.icanhazip.com"

  # Optional request headers
  request_headers {
    "Accept" = "application/json"
  }
}

resource "aws_security_group" "security_group" {
  name = "${var.project}_${aws_vpc.main.id}"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["10.0.0.0/16", "${chomp("${data.http.your_ip.body}")}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project}_allow_all"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    UUID= "${random_id.rval.hex}"
  }
}

output "aws_security_group_id" {
  value = "${aws_security_group.security_group.id}"
}
