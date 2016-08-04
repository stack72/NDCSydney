variable "vpc_id" {
  type = "string"
}

variable "env_prefix" {
  type = "string"
}

variable "ami_id" {
  type    = "string"
  default = "ami-6885af0b" //Ubuntu 16.04
}

variable "instance_type" {
  type    = "string"
  default = "t2.medium"
}

variable "key_name" {
  type = "string"
}

variable "volume_size" {
  type    = "string"
  default = "50"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "min_size" {
  type    = "string"
  default = "0"
}

variable "max_size" {
  type = "string"
}

variable "desired_capacity" {
  type = "string"
}

variable "nginx_config" {
  type = "string"
}

output "discovery_elb_address" {
  value = "${aws_elb.discovery_elb.dns_name}"
}
