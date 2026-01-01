variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Name → CIDR (use any names you like)
variable "public_subnets" {
  type = map(string)
  default = {
    public-a = "10.0.1.0/24"
    public-b = "10.0.2.0/24"
  }
}

variable "private_subnets" {
  type = map(string)
  default = {
    private-a = "10.0.101.0/24"
    private-b = "10.0.102.0/24"
  }
}

# How many AZs to use from the region (take the first N)
variable "az_count" {
  type    = number
  default = 2
}

variable "image" {
  type = string
}

variable "bucket_name" {
  type = string
  default = "frontend"
}