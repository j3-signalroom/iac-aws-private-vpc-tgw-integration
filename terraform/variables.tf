# ===================================================
# AWS PROVIDER CONFIGURATION
# ===================================================
variable "aws_region" {
    description = "The AWS Region."
    type        = string
}

variable "aws_access_key_id" {
    description = "The AWS Access Key ID."
    type        = string
    default     = ""
}

variable "aws_secret_access_key" {
    description = "The AWS Secret Access Key."
    type        = string
    default     = ""
}

variable "aws_session_token" {
    description = "The AWS Session Token."
    type        = string
    default     = ""
}

# ===================================================
# TERRAFORM CLOUD CONFIGURATION
# ===================================================
variable "tfe_token" {
  description = "Terraform Cloud API Token"
  type        = string
#  sensitive   = true
  default     = ""
}

# ===================================================
# VPC CONFIGURATION
# ===================================================
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "Desired subnet prefix (e.g., 24 for /24)"
  type        = number
  default     = 24
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
}

variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "vpc_name" {
  description = "Repositpory name"
  type        = string
  default     = "signalroom"
}

locals {
  vpc_prefix = tonumber(split("/", var.vpc_cidr)[1])
  newbits    = var.subnet_prefix - local.vpc_prefix
}