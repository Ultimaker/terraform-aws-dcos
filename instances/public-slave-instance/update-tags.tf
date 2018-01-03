resource "null_resource" "update-tags" {
  count = "${var.number_of_instances}"

  triggers {
    file_hash     = "${sha1(file("${path.module}/instance.tf"))}"
    instance_type = "${element(aws_instance.public-slave.*.instance_type, count.index)}"
  }

  connection {
    host = "${element(aws_instance.public-slave.*.public_ip, count.index)}"
    user = "${var.instance_ami_user}"
  }

  provisioner "file" {
    destination = "/tmp/mesos-slave-common"

    content = <<EOF
MESOS_ATTRIBUTES=role:public;region:${var.region};availability-zone:${element(aws_instance.public-slave.*.availability_zone, count.index)};public-ip:${element(aws_instance.public-slave.*.public_ip, count.index)};public-dns:${element(aws_instance.public-slave.*.public_dns, count.index)};instance-type:${var.instance_type}
EOF
  }

  provisioner "remote-exec" {
    inline = ["sudo mv /tmp/mesos-slave-common /var/lib/dcos/mesos-slave-common"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop dcos-mesos-slave-public || true",
      "sudo mv /var/log/mesos/mesos-agent.log /var/log/mesos/mesos-agent-backup.log || true",
      "sudo mv /var/lib/mesos/slave/meta/slaves/latest/slave.info /tmp/mesos-slave-backup.info || true",
      "sudo systemctl start dcos-mesos-slave-public || true",
    ]
  }
}
