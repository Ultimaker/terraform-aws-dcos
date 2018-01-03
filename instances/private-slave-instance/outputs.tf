output "private-slave-private-ip-list" {
  value = ["${aws_instance.private-slave.*.private_ip}"]
}
