# terraform {
#   required_version = ">= 1.3"
#   backend "s3" {
#     bucket         = "your-tf-state-bucket"
#     key            = "fargate/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#   }

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./Modules/network"
  name   = var.project_name
  cidr   = "10.0.0.0/16"
  azs    = ["us-east-1a", "us-east-1b"]
}

module "ecs" {
  source              = "./Modules/ecs"
  cluster_name        = "${var.project_name}-cluster"
  alb_subnets         = module.network.public_subnets
  service_subnets     = module.network.private_subnets
  vpc_id              = module.network.vpc_id
  container_definitions = [
    {
      name         = "patient-service"

      container_port = 3000
      path          = "/patient"
      image         = "your_ecr_repo/patient-service:latest"
    },
    {
      name         = "appointment-service"
      container_port = 3001
      path          = "/appointment"
      image         = "your_ecr_repo/appointment-service:latest"
    }
  ]
}
