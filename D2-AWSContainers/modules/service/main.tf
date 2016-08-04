resource "aws_ecs_service" "main" {
  name            = "${module.task.name}"
  cluster         = "${var.cluster}"
  task_definition = "${module.task.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.iam_role}"

  load_balancer {
    elb_name       = "${module.elb.id}"
    container_name = "${var.name}"
    container_port = "${var.container_port}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "task" {
  source = "../task"

  environment   = "${var.environment}"
  name          = "${var.name}"
  image         = "${var.image}"
  image_version = "${var.version}"
  command       = "${var.command}"
  env_vars      = "${var.env_vars}"
  memory        = "${var.memory}"
  cpu           = "${var.cpu}"

  ports = <<EOF
  [
    {
      "containerPort": ${var.container_port},
      "hostPort": ${var.port}
    }
  ]
EOF
}

module "elb" {
  source = "../elb"

  name            = "${module.task.name}"
  port            = "${var.port}"
  environment     = "${var.environment}"
  subnet_ids      = ["${var.subnet_ids}"]
  security_groups = ["${var.security_groups}"]
  healthcheck     = "${var.healthcheck}"
  health_port     = "${var.port}"
  protocol        = "${var.protocol}"
}
