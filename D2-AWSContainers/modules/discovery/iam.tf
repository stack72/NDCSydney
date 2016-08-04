resource "aws_iam_role" "default_discovery_role" {
  name = "discovery-role-${var.env_prefix}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "default_discovery" {
  name  = "discovery-instance-profile-${var.env_prefix}"
  path  = "/"
  roles = ["${aws_iam_role.default_discovery_role.name}"]
}
