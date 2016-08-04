resource "aws_security_group" "discovery" {
  name        = "${format("%s-discovery-sg", var.env_prefix)}"
  description = "Discovery Security Group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.discovery_elb.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.discovery_elb.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Discovery Node"
  }
}

resource "aws_security_group" "discovery_elb" {
  name        = "${format("%s-discovery-elb-sg", var.env_prefix)}"
  description = "Discovery Elastic Load Balancer Security Group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Discovery Load Balancer"
  }
}

resource "aws_launch_configuration" "discovery_launch_config" {
  name_prefix                 = "${format("%s-discovery-conf-", var.env_prefix)}"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.default_discovery.id}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.discovery.id}"]
  associate_public_ip_address = false

  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y nginx
sudo sh -c "echo '${var.nginx_config}' > /etc/nginx/nginx.conf"
EOF

  root_block_device {
    volume_size = "${var.volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "discovery" {
  name                 = "${format("%s-discovery", var.env_prefix)}"
  vpc_zone_identifier  = ["${var.private_subnet_ids}"]
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.discovery_launch_config.name}"
  health_check_type    = "EC2"
  load_balancers       = ["${aws_elb.discovery_elb.name}"]

  tag {
    key                 = "Name"
    value               = "discovery-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.env_prefix}"
    propagate_at_launch = true
  }
}

resource "aws_elb" "discovery_elb" {
  name                      = "${format("%s-discovery-elb", var.env_prefix)}"
  subnets                   = ["${var.public_subnet_ids}"]
  security_groups           = ["${aws_security_group.discovery_elb.id}"]
  cross_zone_load_balancing = true
  connection_draining       = true
  internal                  = false

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    target              = "HTTP:80/"
    timeout             = 5
  }
}
