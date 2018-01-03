resource "aws_instance" "private-slave" {
  count = "${var.number_of_instances}"

  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"

  vpc_security_group_ids = ["${var.security_groups}"]
  subnet_id              = "${element(var.subnets, count.index % length(var.subnets))}"

  key_name = "${var.key_name}"

  root_block_device {
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
  }

  connection {
    user         = "${var.instance_ami_user}"
    bastion_host = "${var.bastion_host}"
    agent        = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl disable locksmithd",
      "sudo systemctl stop locksmithd",
      "sudo systemctl disable update-engine",
      "sudo systemctl stop update-engine",
      "sudo systemctl restart docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "until $(curl --output /dev/null --silent --head --fail http://${var.bootstrap_ip}:${var.bootstrap_port}/dcos_install.sh); do printf 'waiting for bootstrap node to serve...'; sleep 10; done",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/dcos && cd /tmp/dcos",
      "/usr/bin/curl -O http://${var.bootstrap_ip}:${var.bootstrap_port}/dcos_install.sh",
      "sudo bash dcos_install.sh slave",
    ]
  }

  tags {
    Name         = "dcos-private-slave"
    cluster      = "${var.cluster_id}"
    bootstrap-id = "${var.bootstrap_id}"
    master-list  = "${join(",", var.wait_for_masters)}"
  }

  volume_tags {
    Name         = "dcos-private-slave"
    cluster      = "${var.cluster_id}"
    bootstrap-id = "${var.bootstrap_id}"
  }

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      "tags.master-list",
      "tags.bootstrap-id",
      "volume_tags.bootstrap_id",
    ]
  }
}
