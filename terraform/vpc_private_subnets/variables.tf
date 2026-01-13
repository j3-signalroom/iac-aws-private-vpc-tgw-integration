variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "new_bits" {
    description = "New bit"
    type = number
}