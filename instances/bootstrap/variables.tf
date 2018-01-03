variable "cluster_name" {
  type        = "string"
  description = "The name of this DC/OS cluster."
}

variable "cluster_id" {
  type        = "string"
  description = "An identifier for this cluster."
}

variable "region" {
  type        = "string"
  description = "The instance will be tagged with this region identifier"
}

variable "dcos_stability" {
  type        = "string"
  description = "The stability level of DC/OS."
}

variable "dcos_version" {
  type        = "string"
  description = "The version of DC/OS to install."
}

variable "key_name" {
  type        = "string"
  description = "The public/private key pair to use."
}

variable "volume_type" {
  type        = "string"
  description = "The volume type used for all instances (gp2, io1)."
}

variable "volume_size" {
  type        = "string"
  description = "The volume size in GB used for all instances."
}

variable "instance_type" {
  type        = "string"
  description = "The instance type this instance should be."
}

variable "subnet_id" {
  type        = "string"
  description = "The subnet this instance should be in."
}

variable "vpc_endpoint_id" {
  type        = "string"
  description = "The VPC Endpoint to allow traffic to the DC/OS Exhbitor S3 bucket from."
}

variable "instance_ami" {
  type        = "string"
  description = "The AMI to use for this instance."
}

variable "instance_ami_user" {
  type        = "string"
  description = "The user to use to log in to this instance."
}

variable "security_groups" {
  type        = "list"
  description = "A list of security groups that should be added."
}

variable "number_of_masters" {
  type        = "string"
  description = "The number of master instances that will be active in this cluster."
}

variable "master_elb_dns_address" {
  type        = "string"
  description = "The DNS address of the master load balancer."
}

variable "bootstrap_port" {
  type        = "string"
  description = "The port to serve the bootstrap files from."
}

variable "dcos_config" {
  type        = "string"
  description = "The generated dcos-config.yml file for this cluster."
}
