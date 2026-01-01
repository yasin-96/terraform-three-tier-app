provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-three-tier"
    key            = "three-tier-app/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}


module "networking" {
  source = "./modules/networking"
  az_count = var.az_count
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  vpc_cidr = var.vpc_cidr
}

module "container" {
  aws_region = var.region
  source = "./modules/container"
  public_subnet_ids = module.networking.private_subnet_ids
  vpc_id = module.networking.vpc_id
  region = var.region
  image = var.image
  private_subnet_ids = module.networking.private_subnet_ids
}
/*
module "frontend" {
  source = "./modules/frontend"
  bucket_name = var.bucket_name
}*/