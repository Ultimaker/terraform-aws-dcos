terraform {
  required_version = ">= 0.10.1"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "dcos-key" {
  key_name   = "${var.cluster_id}"
  public_key = "${var.public_key}"
}

module "bootstrap-node" {
  source = "../instances/bootstrap"

  cluster_id   = "${var.cluster_id}"
  cluster_name = "${var.cluster_name}"

  dcos_stability = "${var.dcos_stability}"
  dcos_version   = "${var.dcos_version}"

  key_name = "${aws_key_pair.dcos-key.id}"

  instance_type     = "${var.master_instance_type}"
  instance_ami      = "${data.aws_ami.operating-system-ami.id}"
  instance_ami_user = "${var.operating_system_user}"

  volume_type = "${var.volume_type}"
  volume_size = "${var.volume_size}"

  subnet_id = "${element(aws_subnet.public-subnet.*.id, 0)}"

  security_groups = [
    "${aws_security_group.internal-bootstrap-http-access.id}",
    "${aws_security_group.internet-access.id}",
    "${aws_security_group.admin-ssh-access.id}",
  ]

  master_elb_dns_address = "${aws_lb.master-prvt-lb.dns_name}"
  number_of_masters      = "${var.master_number_of_instances}"

  region = "${var.region}"

  bootstrap_port = "${var.bootstrap_port}"

  vpc_endpoint_id = "${aws_vpc_endpoint.private-s3-endpoint.id}"

  dcos_config = "${var.dcos_config}"
}

module "master-instances" {
  source = "../instances/master-instance"

  number_of_instances = "${var.master_number_of_instances}"

  cluster_id = "${var.cluster_id}"

  key_name = "${aws_key_pair.dcos-key.key_name}"

  instance_type     = "${var.master_instance_type}"
  instance_ami      = "${data.aws_ami.operating-system-ami.id}"
  instance_ami_user = "${var.operating_system_user}"

  volume_type = "${var.volume_type}"
  volume_size = "${var.volume_size}"

  subnets = ["${aws_subnet.master-subnet.*.id}"]

  security_groups = [
    "${aws_security_group.internet-access.id}",
    "${aws_security_group.internal-access-full.id}",
    "${aws_security_group.admin-http-access.id}",
    "${aws_security_group.admin-ssh-access.id}",
  ]

  bootstrap_id   = "${module.bootstrap-node.bootstrap-id}"
  bootstrap_ip   = "${module.bootstrap-node.bootstrap-ip}"
  bootstrap_port = "${var.bootstrap_port}"

  serve_https          = "${var.ssl_certificate_arn == "" ? false : true}"
  public_tg_arn__http  = ["${aws_lb_target_group.master-pub-tg--http.*.arn}"]
  public_tg_arn__https = ["${aws_lb_target_group.master-pub-tg--https.*.arn}"]

  private_tg_arn__zk           = "${aws_lb_target_group.master-prvt-tg--zk.arn}"
  private_tg_arn__zk-exhibitor = "${aws_lb_target_group.master-prvt-tg--zk-exhbtr.arn}"
  private_tg_arn__mesos        = "${aws_lb_target_group.master-prvt-tg--mesos.arn}"
  private_tg_arn__marathon     = "${aws_lb_target_group.master-prvt-tg--marathon.arn}"
  private_tg_arn__https        = "${aws_lb_target_group.master-prvt-tg--https.arn}"
  private_tg_arn__http         = "${aws_lb_target_group.master-prvt-tg--http.arn}"
}

module "public-slave-instances" {
  source = "../instances/public-slave-instance"

  number_of_instances = "${var.public_slave_number_of_instances}"

  cluster_id = "${var.cluster_id}"

  key_name = "${aws_key_pair.dcos-key.key_name}"

  instance_type     = "${var.public_slave_instance_type}"
  instance_ami      = "${data.aws_ami.operating-system-ami.id}"
  instance_ami_user = "${var.operating_system_user}"

  volume_type = "${var.volume_type}"
  volume_size = "${var.volume_size}"

  subnets = ["${aws_subnet.public-subnet.*.id}"]

  security_groups = [
    "${aws_security_group.internet-access.id}",
    "${aws_security_group.internal-access-full.id}",
    "${aws_security_group.public-http-access.id}",
    "${aws_security_group.admin-full-access.id}",
    "${aws_security_group.admin-ssh-access.id}",
  ]

  region = "${var.region}"

  bootstrap_id   = "${module.bootstrap-node.bootstrap-id}"
  bootstrap_ip   = "${module.bootstrap-node.bootstrap-ip}"
  bootstrap_port = "${var.bootstrap_port}"

  serve_https           = "${var.ssl_certificate_arn == "" ? false : true}"
  public_tg_arn--http   = "${aws_lb_target_group.pub-slv-tg-pub--http.arn}"
  public_tg_arn--https  = ["${aws_lb_target_group.pub-slv-tg-pub--https.*.arn}"]
  private_tg_arn--http  = "${aws_lb_target_group.pub-slv-tg-prvt--http.arn}"
  private_tg_arn--https = ["${aws_lb_target_group.pub-slv-tg-prvt--https.*.arn}"]

  wait_for_masters = ["${module.master-instances.master-private-ip-list}"]
}

module "private-slave-instances" {
  source = "../instances/private-slave-instance"

  number_of_instances = "${var.private_slave_number_of_instances}"

  cluster_id = "${var.cluster_id}"

  key_name = "${aws_key_pair.dcos-key.key_name}"

  instance_type     = "${var.private_slave_instance_type}"
  instance_ami      = "${data.aws_ami.operating-system-ami.id}"
  instance_ami_user = "${var.operating_system_user}"

  volume_type = "${var.volume_type}"
  volume_size = "${var.volume_size}"

  subnets = ["${aws_subnet.private-subnet.*.id}"]

  security_groups = [
    "${aws_security_group.internet-access.id}",
    "${aws_security_group.internal-access-full.id}",
  ]

  region = "${var.region}"

  bootstrap_id   = "${module.bootstrap-node.bootstrap-id}"
  bootstrap_ip   = "${module.bootstrap-node.bootstrap-ip}"
  bootstrap_port = "${var.bootstrap_port}"

  bastion_host = "${module.bootstrap-node.bastion-ip}"

  wait_for_masters = ["${module.master-instances.master-private-ip-list}"]
}

module "private-gpu-slave-instances" {
  source = "../instances/private-slave-instance"

  number_of_instances = "${var.private_gpu_slave_number_of_instances}"

  cluster_id = "${var.cluster_id}"

  key_name = "${aws_key_pair.dcos-key.key_name}"

  instance_type     = "${var.private_gpu_slave_instance_type}"
  instance_ami      = "${data.aws_ami.operating-system-ami.id}"
  instance_ami_user = "${var.operating_system_user}"

  volume_type = "${var.volume_type}"
  volume_size = "${var.volume_size}"

  subnets = ["${aws_subnet.private-subnet.*.id}"]

  security_groups = [
    "${aws_security_group.internet-access.id}",
    "${aws_security_group.internal-access-full.id}",
  ]

  region = "${var.region}"

  bootstrap_id   = "${module.bootstrap-node.bootstrap-id}"
  bootstrap_ip   = "${module.bootstrap-node.bootstrap-ip}"
  bootstrap_port = "${var.bootstrap_port}"

  bastion_host = "${module.bootstrap-node.bastion-ip}"

  wait_for_masters = ["${module.master-instances.master-private-ip-list}"]
}
