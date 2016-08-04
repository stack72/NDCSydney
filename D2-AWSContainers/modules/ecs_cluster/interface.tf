variable "cluster_name" {
  type = "string"
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

variable "ami_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "env_prefix" {
  type = "string"
}

variable "root_volume_size" {
  default = 25
}

variable "docker_volume_size" {
  default = 25
}

output "ecs_cluster_name" {
  value = "${var.cluster_name}"
}

output "ecs_cluster_id" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "ecs_iam_role_id" {
  value = "${aws_iam_role.default_ecs_role.arn}"
}

output "ecs_sg_id" {
  value = "${aws_security_group.ecs_cluster.id}"
}
