variable "name" {
  description = "ELB name, e.g cdn"
}

variable "subnet_ids" {
  type        = "list"
  description = "Comma separated list of subnet IDs"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "port" {
  description = "Instance port"
}

variable "security_groups" {
  type        = "list"
  description = "Comma separated list of security group IDs"
}

variable "healthcheck" {
  description = "Healthcheck path"
}

variable "health_port" {
  description = "Healthcheck port"
}

variable "protocol" {
  description = "Protocol to use, HTTP or TCP"
}

output "id" {
  value = "${aws_elb.main.id}"
}

output "dns" {
  value = "${aws_elb.main.dns_name}"
}
