output "private-master-lb-dns" {
  value = "${aws_lb.master-prvt-lb.dns_name}"
}

output "bastion-ip" {
  value = "${module.bootstrap-node.bastion-ip}"
}

output "bootstrap-ip" {
  value = "${module.bootstrap-node.bootstrap-ip}"
}

output "bootstrap-port" {
  value = "${var.bootstrap_port}"
}

output "number-of-masters" {
  value = "${var.master_number_of_instances}"
}

output "exhibitor-bucket" {
  value = "${module.bootstrap-node.exhibitor-bucket}"
}

output "master-public-ip-list" {
  value = ["${module.master-instances.master-public-ip-list}"]
}

output "public-slave-public-ip-list" {
  value = ["${module.public-slave-instances.public-slave-public-ip-list}"]
}

output "private-slave-private-ip-list" {
  value = [
    "${module.private-slave-instances.private-slave-private-ip-list}",
    "${module.private-gpu-slave-instances.private-slave-private-ip-list}",
  ]
}
