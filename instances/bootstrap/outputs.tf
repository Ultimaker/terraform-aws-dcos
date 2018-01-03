output "bootstrap-ip" {
  value = "${aws_instance.bootstrap-node.private_ip}"
}

output "bastion-ip" {
  value = "${aws_instance.bootstrap-node.public_ip}"
}

output "bootstrap-id" {
  value = "${null_resource.bootstrap-node-provision.id}"
}

output "exhibitor-bucket" {
  value = "${aws_s3_bucket.dcos-exihibitor.bucket}"
}
