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
  default     = "github-actions-pat"
}
