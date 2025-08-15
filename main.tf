terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region  # Change to your desired region
}

module "nexus_instance" {
  source       = "./ec2_instance"
  ami          = var.aws_ami  # Example AMI ID, replace with your desired AMI
  instance_type = var.aws_type             # Example instance type, replace with your desired type
  instance_name = "nexus"
}

module "sonar_instance" {
  source       = "./ec2_instance"
  ami          = var.aws_ami  # Example AMI ID, replace with your desired AMI
  instance_type = var.aws_type              # Example instance type, replace with your desired type
  instance_name = "sonar"
}

module "test_instance" {
  source       = "./ec2_instance"
  ami          = var.aws_ami  # Example AMI ID, replace with your desired AMI
  instance_type = var.aws_type              # Example instance type, replace with your desired type
  instance_name = "test"
}
