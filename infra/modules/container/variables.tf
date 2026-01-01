variable "public_subnet_ids" {
  description = "List of public subnet IDs where containers or load balancers will be deployed"
  type        = list(string)
}

variable "vpc_id" {
  type = string
}

variable "image" {
  type = string
}

variable "region" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "aws_region" {
  type = string
}