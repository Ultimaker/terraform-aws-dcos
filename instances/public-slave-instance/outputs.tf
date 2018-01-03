output "public-slave-public-ip-list" {
  value = ["${aws_instance.public-slave.*.public_ip}"]
}

output "public-slave-private-ip-list" {
  value = ["${aws_instance.public-slave.*.private_ip}"]
}
