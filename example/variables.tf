variable "region" {
  type        = "string"
  description = "The region to deploy this cluster in."

  default = "eu-west-1"
}

variable "cluster_name" {
  type        = "string"
  description = "The name of this cluster."

  default = "DC/OS Cluster"
}

variable "public_key" {
  type        = "string"
  description = "The public key used to authenticate with instances."
}
