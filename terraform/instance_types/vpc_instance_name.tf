##################################################################################################################
###  PROVIDER
##################################################################################################################
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.35.0"
    }
  }
}

provider "aws" {

    region     = var.region
    access_key = var.access_key
    secret_key = var.secret_key

}

##################################################################################################################
###  VARIABLES
##################################################################################################################
variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

variable "region" {
    type = string
}

variable "vpc_root_cidr" {
    type = string
    default = "172.205.0.0/24"
    description = "The CIDR used to create the VPC and the subnets"
}

variable "purpose" {
    type = string
    default = "demo"
    description = "Purpose for this deployment"
}

locals {
  name = "<%=instance.name%>"
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = var.vpc_root_cidr

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = [cidrsubnet(var.vpc_root_cidr, 4, 0)]
  public_subnets  = [cidrsubnet(var.vpc_root_cidr, 4, 1)]

  enable_ipv6 = false

  enable_nat_gateway = false
  single_nat_gateway = false

  private_subnet_tags = {
    "Name" = "${local.name}_priv_subnet"
  }
  public_subnet_tags = {
    "Name" = "${local.name}_pub_subnet"
  }

  tags = {
    Purpose = var.purpose
  }

  vpc_tags = {
    "Name" = "${local.name}_vpc"
  }
}

################################################################################
# IAM Module 
################################################################################

module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4.3"

  name          = "${local.name}_user"
  force_destroy = true

  create_iam_user_login_profile = false
  create_iam_access_key         = true
}