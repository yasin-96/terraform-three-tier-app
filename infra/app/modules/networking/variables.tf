variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  description = "Map of name => CIDR"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of name => CIDR"
  type        = map(string)
}

variable "az_count" {
  type = number
}