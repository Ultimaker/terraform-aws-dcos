output "private-master-lb-dns" {
  value = "${aws_lb.master-prvt-lb.dns_name}"
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
