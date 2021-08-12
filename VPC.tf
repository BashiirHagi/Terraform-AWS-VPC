module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Security group"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.ec2_sg.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "22"
  to_port           = "22"
}

#Launch configuration
resource "aws_launch_configuration" "ec2_lc" {
  name          = "LinuxInstance"
  image_id      = "ami-02e1d642ba3fa06e4"
  instance_type = "t2.micro"
}

#Autoscaling group
resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier       = module.vpc.public_subnets
  name                      = "test_AOG"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  launch_configuration      = aws_launch_configuration.ec2_lc.name
  force_delete              = true


}