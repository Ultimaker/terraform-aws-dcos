resource "aws_instance" "master" {
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
    user  = "${var.instance_ami_user}"
    agent = true
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
      "sudo bash dcos_install.sh master",
    ]
  }

  tags {
    Name         = "dcos-master"
    cluster      = "${var.cluster_id}"
    bootstrap-id = "${var.bootstrap_id}"
  }

  volume_tags {
    Name         = "dcos-master"
    cluster      = "${var.cluster_id}"
    bootstrap-id = "${var.bootstrap_id}"
  }

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      "tags.bootstrap-id",
      "volume_tags.bootstrap_id",
    ]
  }
}

resource "aws_lb_target_group_attachment" "master-public-tga--http" {
  count = "${var.serve_https == false ? var.number_of_instances : 0}"

  target_group_arn = "${element(var.public_tg_arn__http, 0)}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "master-public-tga--https" {
  count = "${var.serve_https == false ? 0 : var.number_of_instances}"

  target_group_arn = "${element(var.public_tg_arn__https, 0)}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "master-private-tga--zk" {
  count = "${var.number_of_instances}"

  target_group_arn = "${var.private_tg_arn__zk}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "master-private-tga--zk-exhibitor" {
  count = "${var.number_of_instances}"

  target_group_arn = "${var.private_tg_arn__zk-exhibitor}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "master-private-tga--mesos" {
  count = "${var.number_of_instances}"

  target_group_arn = "${var.private_tg_arn__mesos}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "master-private-tga--http" {
  count = "${var.number_of_instances}"

  target_group_arn = "${var.private_tg_arn__http}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "master-private-tga--https" {
  count = "${var.number_of_instances}"

  target_group_arn = "${var.private_tg_arn__https}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_lb_target_group_attachment" "master-private-tga--marathon" {
  count = "${var.number_of_instances}"

  target_group_arn = "${var.private_tg_arn__marathon}"
  target_id        = "${element(aws_instance.master.*.id, count.index)}"
}
