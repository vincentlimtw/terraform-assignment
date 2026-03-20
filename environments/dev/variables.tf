# -----------------------------------------------------------------------------
# Region & Environment
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "prefix" {
  description = "Prefix for all resource names"
  default     = "echoserver"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}