resource "aws_elb" "main" {
  name = "${var.name}"

  internal                  = true
  cross_zone_load_balancing = true
  subnets                   = ["${var.subnet_ids}"]
  security_groups           = ["${var.security_groups}"]

  idle_timeout                = 30
  connection_draining         = true
  connection_draining_timeout = 15

  listener {
    lb_port           = 80
    lb_protocol       = "${var.protocol}"
    instance_port     = "${var.port}"
    instance_protocol = "${var.protocol}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "${var.protocol}:${var.health_port}${var.healthcheck}"
    interval            = 30
  }

  tags {
    Name        = "${var.name}-balancer"
    Service     = "${var.name}"
    Environment = "${var.environment}"
  }
}
