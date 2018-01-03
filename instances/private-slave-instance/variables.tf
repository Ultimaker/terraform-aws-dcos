variable "cluster_id" {
  type        = "string"
  description = "An identifier for this cluster."
}

variable "region" {
  type        = "string"
  description = "The instance will be tagged with this region identifier"
}

variable "number_of_instances" {
  type        = "string"
  description = "The minimum amount of instances that should always run."
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

variable "subnets" {
  type        = "list"
  description = "The subnets this instance may be in."
}

variable "instance_ami" {
  type        = "string"
  description = "The AMI to use for this instance."
}

variable "instance_ami_user" {
  type        = "string"
  description = "The user to use to log in to this instance."
}

variable "key_name" {
  type        = "string"
  description = "The key to use for this instance."
}

variable "security_groups" {
  type        = "list"
  description = "A list of security groups that should be added."
}

variable "bastion_host" {
  type        = "string"
  description = "The bastion host to use to log in to private instances."
}

variable "bootstrap_ip" {
  type        = "string"
  description = "The IP the bootstrap files will be served from."
}

variable "bootstrap_port" {
  type        = "string"
  description = "The port the bootstrap files will be served from."
}

variable "bootstrap_id" {
  type = "string"

  # This is kind of a hack, to force the null_resource to run before
  # creating this instance.
  description = "The null_resource id used to provision this instance."
}

variable "wait_for_masters" {
  type        = "list"
  description = "Force slaves to be spawn until masters are ready."
}
