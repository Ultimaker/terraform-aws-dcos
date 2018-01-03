variable "cluster_id" {
  type        = "string"
  description = "An identifier for this cluster."
}

variable "number_of_instances" {
  type        = "string"
  description = "The number of master instances to spin up."
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

variable "serve_https" {
  type        = "string"
  description = "Serve the HTTPS endpoints."

  default = false
}

variable "public_tg_arn__http" {
  type        = "list"
  description = "The public loadbalancer these masters should be accessible through."

  default = []
}

variable "public_tg_arn__https" {
  type        = "list"
  description = "The public loadbalancer these masters should be accessible through."

  default = []
}

variable "private_tg_arn__zk" {
  type        = "string"
  description = "The private loadbalancer used to discover master instances."
}

variable "private_tg_arn__zk-exhibitor" {
  type        = "string"
  description = "The private loadbalancer used to discover master instances."
}

variable "private_tg_arn__mesos" {
  type        = "string"
  description = "The private loadbalancer used to discover master instances."
}

variable "private_tg_arn__marathon" {
  type        = "string"
  description = "The private loadbalancer used to discover master instances."
}

variable "private_tg_arn__http" {
  type        = "string"
  description = "The private loadbalancer used to discover master instances."
}

variable "private_tg_arn__https" {
  type        = "string"
  description = "The private loadbalancer used to discover master instances."
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
