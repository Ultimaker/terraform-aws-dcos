resource "aws_security_group" "internal-access-full" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks      = ["${aws_vpc.master-region-vpc.cidr_block}"]
    ipv6_cidr_blocks = ["${aws_vpc.master-region-vpc.ipv6_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks      = ["${aws_vpc.master-region-vpc.cidr_block}"]
    ipv6_cidr_blocks = ["${aws_vpc.master-region-vpc.ipv6_cidr_block}"]
  }

  tags {
    Name    = "dcos-internal-access-full"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_security_group" "internal-bootstrap-http-access" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  ingress {
    from_port = "${var.bootstrap_port}"
    to_port   = "${var.bootstrap_port}"
    protocol  = "tcp"

    cidr_blocks      = ["${aws_vpc.master-region-vpc.cidr_block}"]
    ipv6_cidr_blocks = ["${aws_vpc.master-region-vpc.ipv6_cidr_block}"]
  }

  tags {
    Name    = "dcos-internal-bootstrap-http-access"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_security_group" "public-http-access" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name    = "dcos-public-http-access"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_security_group" "admin-http-access" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["${var.admin_cidr}"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["${var.admin_cidr}"]
  }

  tags {
    Name    = "dcos-admin-http-access"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_security_group" "admin-full-access" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["${var.admin_cidr}"]
  }

  tags {
    Name    = "dcos-admin-full-access"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_security_group" "admin-ssh-access" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.admin_cidr}"]
  }

  tags {
    Name    = "dcos-admin-ssh-access"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_security_group" "internet-access" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name    = "dcos-internet-access"
    cluster = "${var.cluster_id}"
  }
}
