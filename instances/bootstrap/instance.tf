resource "aws_instance" "bootstrap-node" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"

  key_name = "${var.key_name}"

  subnet_id = "${var.subnet_id}"

  vpc_security_group_ids = ["${var.security_groups}"]

  associate_public_ip_address = true

  connection {
    user  = "${var.instance_ami_user}"
    agent = true
  }

  root_block_device {
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
  }

  # We update by updating the AMI used, so disable
  # the default updating mechanism in CoreOS.
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl disable locksmithd",
      "sudo systemctl stop locksmithd",
      "sudo systemctl disable update-engine",
      "sudo systemctl stop update-engine",
      "sudo systemctl restart docker",
    ]
  }

  tags {
    Name    = "dcos-bootstrap-node"
    cluster = "${var.cluster_id}"
  }

  volume_tags {
    Name    = "dcos-bootstrap-node"
    cluster = "${var.cluster_id}"
  }
}

resource "null_resource" "bootstrap-node-provision" {
  triggers {
    template_file = "${sha1(var.dcos_config)}"
    file_hash     = "${sha1(file("${path.module}/instance.tf"))}"
  }

  connection {
    host  = "${aws_instance.bootstrap-node.public_ip}"
    user  = "${var.instance_ami_user}"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/core/dcos/genconf",
      "sudo chmod -R 777 /home/core/dcos",
    ]
  }

  provisioner "file" {
    destination = "/home/core/dcos/genconf/config.yaml"
    content     = "${var.dcos_config}"
  }

  provisioner "file" {
    destination = "/home/core/dcos/genconf/ip-detect"
    content     = "${data.template_file.ip-detect.rendered}"
  }

  provisioner "file" {
    destination = "/home/core/dcos/genconf/ip-detect-public"
    content     = "${data.template_file.ip-detect-public.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/core/dcos",
      "curl -O https://downloads.dcos.io/dcos/${var.dcos_stability}/${var.dcos_version}/dcos_generate_config.sh",
      "sudo bash dcos_generate_config.sh",
      "docker rm -f $(docker ps -a -q -f ancestor=nginx)",
      "docker run -d --name=${var.cluster_id}-bootstrap --restart=always -p ${var.bootstrap_port}:80 -v $PWD/genconf/serve:/usr/share/nginx/html:ro nginx",
    ]
  }
}
