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
  description = "The AWS region to use for this master-region."
}

variable "dcos_stability" {
  type        = "string"
  description = "The stability level of DC/OS."

  # https://downloads.dcos.io/dcos/${dcos_stability}/1.10.2/dcos_generate_config.sh
  default = "stable"
}

variable "dcos_version" {
  type        = "string"
  description = "The version of DC/OS to install."

  # https://downloads.dcos.io/dcos/stable/${dcos_version}/dcos_generate_config.sh
  default = "1.10.2"
}

variable "volume_type" {
  type        = "string"
  description = "The volume type used for all instances (gp2, io1)."

  default = "gp2"
}

variable "volume_size" {
  type        = "string"
  description = "The volume size in GB used for all instances."

  default = "128"
}

variable "public_key" {
  type        = "string"
  description = "The key to use for this region."
}

variable "admin_cidr" {
  type        = "list"
  description = "The CIDRs where admins will access from."
}

variable "vpc_cidr" {
  type        = "string"
  description = "The CIDR block to use for this master-region."
}

variable "operating_system" {
  type        = "string"
  description = "The operating system to use in this region."

  default = "CoreOS-stable-1465.8.0-hvm"
}

variable "operating_system_user" {
  type        = "string"
  description = "The default user of the operating system."

  default = "core"
}

variable "enable_ipv6" {
  type = "string"
  description = "Enable IPv6 addresses."

  default = true
}

variable "ssl_certificate_arn" {
  type        = "string"
  description = "The SSL certificate arn used to secure the loadbalancers."

  default = ""
}

variable "ssl_policy" {
  type        = "string"
  description = "The SSL policy to use on the loadbalancers."

  # The SSL policy to use when variable `ssl_certificate_arn` is set.
  #
  # Docs: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "master_instance_type" {
  type        = "string"
  description = "The AWS instance type to use for masters in this region."
}

variable "master_number_of_instances" {
  type        = "string"
  description = "The number of masters to run in this region."
}

variable "public_slave_instance_type" {
  type        = "string"
  description = "The AWS instance type to use for public slaves."
}

variable "public_slave_number_of_instances" {
  type        = "string"
  description = "The number of public slaves to run in this region."
}

variable "private_slave_instance_type" {
  type        = "string"
  description = "The AWS instance type to use for private slaves."
}

variable "private_slave_number_of_instances" {
  type        = "string"
  description = "The number of private slaves to run in this region."
}

variable "private_gpu_slave_instance_type" {
  type        = "string"
  description = "The AWS instance type to use for private GPU slaves."

  default = "p2.xlarge"
}

variable "private_gpu_slave_number_of_instances" {
  type        = "string"
  description = "The number of private GPU slaves to run in this region."

  default = "0"
}

variable "dcos_config" {
  type        = "string"
  description = "The generated dcos-config.yml file."
}

variable "bootstrap_port" {
  type        = "string"
  description = "The port to serve the bootstrap files on."

  default = "8080"
}

variable "lb_log_principal" {
  type = "map"

  # For documentation on this principal ID, see http://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#w377aac17b9c15b9c12b3b5b3
  description = "The principal id to allow access to the loadbalancer log S3 bucket."

  default = {
    us-east-1      = "127311923021"
    us-east-2      = "033677994240"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
    ca-central-1   = "985666609251"
    eu-west-1      = "156460612806"
    eu-central-1   = "054676820928"
    eu-west-2      = "652711504416"
    ap-northeast-1 = "582318560864"
    ap-northeast-2 = "600734575887"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    ap-south-1     = "718504428378"
    sa-east-1      = "507241528517"
  }
}
