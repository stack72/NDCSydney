resource "aws_security_group" "ecs_cluster" {
  name        = "${format("%s-ecs-cluster-sg", var.env_prefix)}"
  description = "Configure Cluster Security"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.cluster_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "ecs_cluster" {
  name_prefix                 = "${format("%s-ecs-cluster-conf-", var.env_prefix)}"
  instance_type               = "${var.instance_type}"
  image_id                    = "${var.ami_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.default_ecs.id}"
  associate_public_ip_address = false

  security_groups = [
    "${aws_security_group.ecs_cluster.id}",
  ]

  user_data = <<EOF
#!/bin/bash
echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" >> /etc/ecs/ecs.config
EOF

  key_name = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }

  # docker
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = "${var.docker_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_cluster" {
  name                 = "${format("%s-ecs-cluster", var.env_prefix)}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.ecs_cluster.name}"
  health_check_type    = "EC2"

  tag {
    key                 = "Name"
    value               = "ecs-cluster-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.env_prefix}"
    propagate_at_launch = true
  }
}
