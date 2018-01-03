#
# DC/OS Master - internal loadbalancer
#
# This loadbalancer is used by DC/OS slaves to find
# masters. It is not accessible from outside the VPC.
#
resource "aws_lb" "master-prvt-lb" {
  name = "dcos-prvt-master-lb"

  internal           = true
  load_balancer_type = "network"

  subnets = ["${aws_subnet.master-subnet.*.id}"]

  tags {
    cluster = "${var.cluster_id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "master-prvt-tg--zk" {
  name = "dcos-master-prvt-tg--zk"

  port     = 2181
  protocol = "TCP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-prvt-lb-listener--zk" {
  port              = 2181
  protocol          = "TCP"
  load_balancer_arn = "${aws_lb.master-prvt-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-prvt-tg--zk.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "master-prvt-tg--zk-exhbtr" {
  name = "dcos-master-prvt-tg--zk-exhbtr"

  port     = 8181
  protocol = "TCP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-prvt-lb-listener--zk-exhbtr" {
  port              = 8181
  protocol          = "TCP"
  load_balancer_arn = "${aws_lb.master-prvt-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-prvt-tg--zk-exhbtr.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "master-prvt-tg--mesos" {
  name = "dcos-master-prvt-tg--mesos"

  port     = 5050
  protocol = "TCP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-prvt-lb-listener--mesos" {
  port              = 5050
  protocol          = "TCP"
  load_balancer_arn = "${aws_lb.master-prvt-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-prvt-tg--mesos.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "master-prvt-tg--http" {
  name = "dcos-master-prvt-tg--http"

  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-prvt-lb-listener--http" {
  port              = 80
  protocol          = "TCP"
  load_balancer_arn = "${aws_lb.master-prvt-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-prvt-tg--http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "master-prvt-tg--https" {
  name = "dcos-master-prvt-tg--https"

  port     = 443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-prvt-lb-listener--https" {
  port              = 443
  protocol          = "TCP"
  load_balancer_arn = "${aws_lb.master-prvt-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-prvt-tg--https.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "master-prvt-tg--marathon" {
  name = "dcos-master-prvt-tg--marathon"

  port     = 8080
  protocol = "TCP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-prvt-lb-listener--marathon" {
  port              = 8080
  protocol          = "TCP"
  load_balancer_arn = "${aws_lb.master-prvt-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-prvt-tg--marathon.arn}"
    type             = "forward"
  }
}

#
# DC/OS Master - public loadbalancer
#
# This "public" loadbalancer is open to Admin CIDR
# to log in to the DC/OS Dashboard. It is not publicly
# accessible.
#
resource "aws_lb" "master-pub-lb" {
  name = "dcos-pub-master-lb"

  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "dualstack"

  subnets = ["${aws_subnet.master-subnet.*.id}"]

  security_groups = [
    "${aws_security_group.admin-http-access.id}",
    "${aws_security_group.internal-access-full.id}",
  ]

  access_logs {
    bucket  = "${aws_s3_bucket.dcos-lb-access-logs.bucket}"
    prefix  = "dcos-pub-master-lb"
    enabled = true
  }

  tags {
    cluster = "${var.cluster_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_s3_bucket_policy.allow-from-loadbalancers"]
}

resource "aws_lb_target_group" "master-pub-tg--http" {
  count = "${var.ssl_certificate_arn == "" ? 1 : 0}"

  name = "dcos-master-pub-tg--http"

  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-pub-lb-listener--http" {
  count = "${var.ssl_certificate_arn == "" ? 1 : 0}"

  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = "${aws_lb.master-pub-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-pub-tg--http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "master-pub-tg--https" {
  count = "${var.ssl_certificate_arn == "" ? 0 : 1}"

  name = "dcos-master-pub-tg--https"

  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "master-pub-lb-listener--https" {
  count = "${var.ssl_certificate_arn == "" ? 0 : 1}"

  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = "${aws_lb.master-pub-lb.arn}"

  ssl_policy      = "${var.ssl_policy}"
  certificate_arn = "${var.ssl_certificate_arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.master-pub-tg--https.arn}"
    type             = "forward"
  }
}

#
# DC/OS Public Slave - public loadbalancer
#
# This will be where the edge routers (marathon-lb) will
# serve requests. It will be the main entrypoint to the
# services running on the cluster for visitors and users
# of our services.
#
resource "aws_lb" "pub-slv-pub-lb" {
  name = "dcos-pub-slv-pub-lb"

  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "dualstack"

  subnets = ["${aws_subnet.public-subnet.*.id}"]

  security_groups = [
    "${aws_security_group.public-http-access.id}",
    "${aws_security_group.internal-access-full.id}",
  ]

  access_logs {
    bucket  = "${aws_s3_bucket.dcos-lb-access-logs.bucket}"
    prefix  = "dcos-pub-slv-pub-lb"
    enabled = true
  }

  tags {
    cluster = "${var.cluster_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_s3_bucket_policy.allow-from-loadbalancers"]
}

resource "aws_lb_target_group" "pub-slv-tg-pub--http" {
  name = "dcos-pub-slv-tg-pub--http"

  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "pub-slv-listener-pub--http" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = "${aws_lb.pub-slv-pub-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.pub-slv-tg-pub--http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "pub-slv-tg-pub--https" {
  count = "${var.ssl_certificate_arn == "" ? 0 : 1}"

  name = "dcos-pub-slv-tg-pub--https"

  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "pub-slv-listener-pub--https" {
  count = "${var.ssl_certificate_arn == "" ? 0 : 1}"

  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = "${aws_lb.pub-slv-pub-lb.arn}"

  ssl_policy      = "${var.ssl_policy}"
  certificate_arn = "${var.ssl_certificate_arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.pub-slv-tg-pub--https.arn}"
    type             = "forward"
  }
}

#
# DC/OS Public Slave - private loadbalancer
#
# This private loadbalancer will serve requests from our
# edge router (marathon-lb) as well, with the main difference
# that DNS names will be mounted here on which test environments
# will be accessible. It will be accessible from ADMIN CIDR.
#
resource "aws_lb" "pub-slv-prvt-lb" {
  name = "dcos-pub-slv-prvt-lb"

  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "dualstack"

  subnets = ["${aws_subnet.public-subnet.*.id}"]

  security_groups = [
    "${aws_security_group.admin-http-access.id}",
    "${aws_security_group.internal-access-full.id}",
  ]

  access_logs {
    bucket  = "${aws_s3_bucket.dcos-lb-access-logs.bucket}"
    prefix  = "dcos-pub-slv-prvt-lb"
    enabled = true
  }

  tags {
    cluster = "${var.cluster_id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_s3_bucket_policy.allow-from-loadbalancers"]
}

resource "aws_lb_target_group" "pub-slv-tg-prvt--http" {
  name = "dcos-pub-slv-tg-prvt--http"

  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "pub-slv-lb-listener-prvt--http" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = "${aws_lb.pub-slv-prvt-lb.arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.pub-slv-tg-prvt--http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "pub-slv-tg-prvt--https" {
  count = "${var.ssl_certificate_arn == "" ? 0 : 1}"

  name = "dcos-pub-slv-tg-prvt--https"

  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.master-region-vpc.id}"

  tags {
    cluster = "${var.cluster_id}"
  }
}

resource "aws_lb_listener" "pub-slv-lb-listener-prvt--https" {
  count = "${var.ssl_certificate_arn == "" ? 0 : 1}"

  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = "${aws_lb.pub-slv-prvt-lb.arn}"

  ssl_policy      = "${var.ssl_policy}"
  certificate_arn = "${var.ssl_certificate_arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.pub-slv-tg-prvt--https.arn}"
    type             = "forward"
  }
}
