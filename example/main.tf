resource "random_id" "cluster-identifier" {
  prefix      = "dcos-"
  byte_length = 4
}

data "template_file" "dcos-config" {
  template = "${file("dcos-config.yml")}"

  vars {
    region = "${var.region}"

    cluster_name = "${var.cluster_name}"
    cluster_id   = "${random_id.cluster-identifier.hex}"

    bootstrap_ip   = "${module.master-region.bootstrap-ip}"
    bootstrap_port = "${module.master-region.bootstrap-port}"

    master_elb_dns_address = "${module.master-region.private-master-lb-dns}"
    number_of_masters      = "${module.master-region.number-of-masters}"

    s3_bucket = "${module.master-region.exhibitor-bucket}"
  }
}

module "master-region" {
  source = "git::ssh://git@github.com/Ultimaker/terraform-aws-dcos.git?ref=master//master-region"

  region = "${var.region}"

  cluster_name = "${var.cluster_name}"
  cluster_id   = "${random_id.cluster-identifier.hex}"

  public_key = "${var.public_key}"

  vpc_cidr   = "10.0.0.0/16"
  admin_cidr = ["0.0.0.0/0"]

  master_instance_type       = "c5.2xlarge"
  master_number_of_instances = "3"

  public_slave_instance_type       = "c5.2xlarge"
  public_slave_number_of_instances = "3"

  private_slave_instance_type       = "c5.2xlarge"
  private_slave_number_of_instances = "6"

  dcos_config = "${data.template_file.dcos-config.rendered}"
}
