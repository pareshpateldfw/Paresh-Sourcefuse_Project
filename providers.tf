# configure aws provider to establish a secure connection between terraform and aws
provider "aws" {
  region  = var.aws_region
  profile = "Paresh_AWS_Profile"

  default_tags {
    tags = {
      "Automation"  = "Sourcefuse_Project"
      "Project"     = var.project_name
      "Environment" = var.environment
    }
  }
}