resource "aws_vpc" "master-region-vpc" {
  cidr_block = "${var.vpc_cidr}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  assign_generated_ipv6_cidr_block = true

  tags {
    Name    = "dcos-vpc"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_subnet" "master-subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id = "${aws_vpc.master-region-vpc.id}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(cidrsubnet(aws_vpc.master-region-vpc.cidr_block, 2, 0), ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)), count.index)}"
  ipv6_cidr_block   = "${cidrsubnet(cidrsubnet(aws_vpc.master-region-vpc.ipv6_cidr_block, 5, 0), ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)), count.index)}"

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = "${var.enable_ipv6}"

  tags {
    Name    = "dcos-master-subnet-${data.aws_availability_zones.available.names[count.index]}"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_subnet" "public-subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id = "${aws_vpc.master-region-vpc.id}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(cidrsubnet(aws_vpc.master-region-vpc.cidr_block, 2, 1), ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)) , count.index)}"
  ipv6_cidr_block   = "${cidrsubnet(cidrsubnet(aws_vpc.master-region-vpc.ipv6_cidr_block, 5, 1), ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)) , count.index)}"

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = "${var.enable_ipv6}"

  tags {
    Name    = "dcos-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_subnet" "private-subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id = "${aws_vpc.master-region-vpc.id}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(cidrsubnet(aws_vpc.master-region-vpc.cidr_block, 1, 1), ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)), count.index)}"
  ipv6_cidr_block   = "${cidrsubnet(cidrsubnet(aws_vpc.master-region-vpc.ipv6_cidr_block, 5, 2), ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)), count.index)}"

  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = "${var.enable_ipv6}"

  tags {
    Name    = "dcos-private-subnet-${data.aws_availability_zones.available.names[count.index]}"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_internet_gateway" "master-region-igw" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  tags {
    Name    = "dcos-master-region-igw"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_vpc_endpoint" "private-s3-endpoint" {
  vpc_id       = "${aws_vpc.master-region-vpc.id}"
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_route_table" "master-region-pub-route-table" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.master-region-igw.id}"
  }

  tags {
    Name    = "dcos-master-region-pub-route-table"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_route" "master-region-pub-route-table-ipv6-route" {
  destination_ipv6_cidr_block = "::/0"

  route_table_id = "${aws_route_table.master-region-pub-route-table.id}"
  gateway_id     = "${aws_internet_gateway.master-region-igw.id}"
}

resource "aws_route_table_association" "main-routes-master-subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"

  route_table_id = "${aws_route_table.master-region-pub-route-table.id}"
  subnet_id      = "${element(aws_subnet.master-subnet.*.id, count.index)}"
}

resource "aws_route_table_association" "main-routes-public-subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"

  route_table_id = "${aws_route_table.master-region-pub-route-table.id}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "private-s3-pub-rta" {
  route_table_id  = "${aws_route_table.master-region-pub-route-table.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.private-s3-endpoint.id}"
}

resource "aws_route_table" "master-region-prvt-route-table" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id = "${aws_vpc.master-region-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.pub-subnet-nat-gw.*.id, count.index)}"
  }

  tags {
    Name    = "dcos-master-region-prvt-routes-${data.aws_availability_zones.available.names[count.index]}"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_egress_only_internet_gateway" "prvt-subnet-egress-ig" {
  vpc_id = "${aws_vpc.master-region-vpc.id}"
}

resource "aws_route" "master-region-prvt-route-table-ipv6-route" {
  count = "${length(data.aws_availability_zones.available.names)}"

  destination_ipv6_cidr_block = "::/0"

  route_table_id         = "${element(aws_route_table.master-region-prvt-route-table.*.id, count.index)}"
  egress_only_gateway_id = "${aws_egress_only_internet_gateway.prvt-subnet-egress-ig.id}"
}

resource "aws_eip" "pub-subnet-nat-eip" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc = true
}

resource "aws_nat_gateway" "pub-subnet-nat-gw" {
  count = "${length(data.aws_availability_zones.available.names)}"

  allocation_id = "${element(aws_eip.pub-subnet-nat-eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public-subnet.*.id, count.index)}"

  tags {
    Name    = "dcos-prvt-subnet-nat-gw-${data.aws_availability_zones.available.names[count.index]}"
    cluster = "${var.cluster_id}"
  }
}

resource "aws_route_table_association" "main-routes-private-subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"

  route_table_id = "${element(aws_route_table.master-region-prvt-route-table.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private-subnet.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "private-s3-prvt-rta" {
  count = "${length(data.aws_availability_zones.available.names)}"

  route_table_id  = "${element(aws_route_table.master-region-prvt-route-table.*.id, count.index)}"
  vpc_endpoint_id = "${aws_vpc_endpoint.private-s3-endpoint.id}"
}
