variable "environment" {
  type        = string
  description = "Deployment environment (dev, prod)"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project name used in resource naming"
  default     = "incident-commander"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair in AWS"
  default     = ""
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed SSH access"
  default     = []
}

variable "availability_zone" {
  type        = string
  description = "AWS availability zone (must support the chosen instance type)"
  default     = "us-east-1a"
}
