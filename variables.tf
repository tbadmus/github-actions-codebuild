# --- Variables ---
# Defines input variables for customization.
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
  default     = "github-runner"
}

variable "github_repo_url" {
  description = "The URL of the GitHub repository (e.g., https://github.com/owner/repo)."
  type        = string
}

variable "github_pat_secret_name" {
  description = "The name of the AWS Secrets Manager secret to store the GitHub PAT."
  type        = string
  default     = "github-actions-pat-lbadmus"
}

variable "vpc_id" {
  description = "The ID of the VPC to launch the CodeBuild project in."
  type        = string
  default     = "vpc-0170011cde1ef44bd"
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the CodeBuild project."
  type        = list(string)
  default     = ["subnet-0d411569cb22d83b7", "subnet-04d78072fc48578ef"]
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the CodeBuild project."
  type        = list(string)
  default     = ["sg-08e9c2963f230a402"]
}
