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
variable "vpc_cidrs" {
  description = "CIDR block for the VPCs (comma-separated)"
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
  default     = 3
}

variable "environment_name" {
  description = "Environment name"
  type        = string
  default     = ""
}

variable "vpc_prefix_name" {
  description = "Repositpory prefix name"
  type        = string
  default     = "signalroom"
}

# ===================================================
# TRANSIT GATEWAY CONFIGURATION
# ===================================================
variable "transit_gateway_id" {
  description = "Identifier of EC2 Transit Gateway."
  type        = string
  default     = ""
}

variable "transit_gateway_route_table_id" {
  description = "Identifier of EC2 Transit Gateway Route Table."
  type        = string
  default     = ""
}