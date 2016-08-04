variable "region" {
  default = "ap-southeast-2"
}
provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "zones" {}
resource "aws_key_pair" "demo_keypair" {
  key_name   = "test_key"
  public_key = "${file("test_key.pub")}"
}

module "ndc_demo_vpc" {
  source = "./modules/vpc"

  name = "NDC Sydney Env"

  cidr            = "10.0.0.0/16"
  private_subnets = ["10.0.160.0/19", "10.0.192.0/19"]
  public_subnets  = ["10.0.0.0/21", "10.0.8.0/21"]

  availability_zones = ["${data.aws_availability_zones.zones.names}"]
}

variable "ecs_ami" {
  default = "ami-d5b59eb6"
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  env_prefix = "demo"

  ami_id           = "${var.ecs_ami}"
  cluster_name     = "demo_cluster"
  desired_capacity = "1"
  max_size         = "3"
  instance_type    = "m3.medium"

  vpc_id     = "${module.ndc_demo_vpc.vpc_id}"
  subnet_ids = ["${module.ndc_demo_vpc.private_subnets}"]
  key_name   = "${aws_key_pair.demo_keypair.key_name}"
}

module "bastion_node" {
  source     = "./modules/bastion"
  env_prefix = "dev"

  vpc_id    = "${module.ndc_demo_vpc.vpc_id}"
  key_name  = "${aws_key_pair.demo_keypair.key_name}"
  subnet_id = "${element(module.ndc_demo_vpc.public_subnets, 0)}"
}

output "bastion_node_address" {
  value = "${module.bastion_node.bastion_node_address}"
}

output "bastion_ssh_command" {
  value = "${format("ssh ec2-user@%s", module.bastion_node.bastion_node_address)}"
}

module "demo_service" {
  source = "./modules/service"

  environment     = "demo"

  //service
  desired_count  = 1
  cluster        = "${module.ecs_cluster.ecs_cluster_name}"
  iam_role       = "${module.ecs_cluster.ecs_iam_role_id}"
  container_port = 80

  //task
  name    = "demo-service"
  image   = "nginx"
  version = "latest"
  memory = "256"
  port = 80

  //elb
  subnet_ids      = "${module.ndc_demo_vpc.private_subnets}"
  protocol        = "HTTP"
  security_groups = ["${module.ecs_cluster.ecs_sg_id}"]
}
output "demo_service_elb_address" {
  value = "${module.demo_service.dns}"
}

data "template_file" "nginx_config" {
  template = "${file("files/nginx.conf.tpl")}"

  vars {
    discovery_endpoint           = "localhost"
    ndc_sydney_elb_address       = "${module.demo_service.dns}"
  }
}

module "discovery" {
  source = "./modules/discovery"

  env_prefix = "dev"

  desired_capacity = "1"
  max_size         = "1"

  vpc_id             = "${module.ndc_demo_vpc.vpc_id}"
  private_subnet_ids = ["${module.ndc_demo_vpc.private_subnets}"]
  key_name           = "${aws_key_pair.demo_keypair.key_name}"
  public_subnet_ids  = ["${module.ndc_demo_vpc.public_subnets}"]

  nginx_config = "${data.template_file.nginx_config.rendered}"
}
output "discovery_elb_address" {
  value = "${module.discovery.discovery_elb_address}"
}
