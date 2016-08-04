variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "image" {
  description = "The docker image name, e.g nginx"
}

variable "name" {
  description = "The service name, if empty the service name is defaulted to the image name"
  default     = ""
}

variable "version" {
  description = "The docker image version"
  default     = "latest"
}

variable "subnet_ids" {
  type        = "list"
  description = "Comma separated list of subnet IDs that will be passed to the ELB module"
}

variable "security_groups" {
  type        = "list"
  description = "Security groups for the service ELB"
}

variable "port" {
  description = "The container host port"
}

variable "cluster" {
  description = "The cluster name or ARN"
}

variable "healthcheck" {
  description = "Path to a healthcheck endpoint"
  default     = "/"
}

variable "container_port" {
  description = "The container port"
}

variable "command" {
  description = "The raw json of the task command"
  default     = "[]"
}

variable "env_vars" {
  description = "The raw json of the task env vars"
  default     = "[]"
}

variable "desired_count" {
  description = "The desired count"
  default     = 2
}

variable "memory" {
  description = "The number of MiB of memory to reserve for the container"
  default     = 512
}

variable "cpu" {
  description = "The number of cpu units to reserve for the container"
  default     = 1
}

variable "protocol" {
  description = "The ELB protocol, HTTP or TCP"
  default     = "HTTP"
}

variable "iam_role" {
  description = "IAM Role ARN to use"
}

output "elb" {
  value = "${module.elb.id}"
}

output "dns" {
  value = "${module.elb.dns}"
}
