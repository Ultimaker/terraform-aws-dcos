output "master-public-ip-list" {
  value = ["${aws_instance.master.*.public_ip}"]
}

output "master-private-ip-list" {
  value = ["${aws_instance.master.*.private_ip}"]
}
