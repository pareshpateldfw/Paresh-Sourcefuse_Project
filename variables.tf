variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "project_name" {}
variable "environment" {}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}
variable "public_subnet_cidr_2" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone_2" {
  description = "Second availability zone for the subnets"
  type        = string
  default     = "us-west-2b"
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-west-2a"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "Sourcefuse_ECS_Cluster"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "Sourcefuse-Project-alb"
}

variable "nginx_image" {
  description = "Docker image for Nginx"
  type        = string
  default     = "nginx:latest"
}

variable "nginx_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "nginx-bucket-sourcefuse-project"
}
