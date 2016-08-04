variable "image" {
  description = "The docker image name, e.g nginx"
}

variable "environment" {
  description = "The name of the environment to which this task belongs"
}

variable "name" {
  description = "The worker name, if empty the service name is defaulted to the image name"
}

variable "cpu" {
  description = "The number of cpu units to reserve for the container"
  default     = 2
}

variable "env_vars" {
  description = "The raw json of the task env vars"
  default     = "[]"
}

variable "command" {
  description = "The raw json of the task command"
  default     = "[]"
}

variable "entry_point" {
  description = "The docker container entry point"
  default     = "[]"
}

variable "ports" {
  description = "The docker container ports"
  default     = "[]"
}

variable "image_version" {
  description = "The docker image version"
  default     = "latest"
}

variable "memory" {
  description = "The number of MiB of memory to reserve for the container"
  default     = 512
}

output "name" {
  value = "${aws_ecs_task_definition.main.family}"
}

output "arn" {
  value = "${aws_ecs_task_definition.main.arn}"
}
