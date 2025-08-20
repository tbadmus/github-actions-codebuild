# --- AWS Secrets Manager for GitHub PAT ---
# Creates a secret in AWS Secrets Manager to securely store the GitHub Personal Access Token (PAT).
# It's crucial to store sensitive data like this securely, not in plaintext.
resource "aws_secretsmanager_secret" "github_pat" {
  name        = var.github_pat_secret_name
  description = "GitHub Personal Access Token for CodeBuild integration"
}

# --- Data Sources ---
# Fetches the current AWS account ID to construct ARNs dynamically.
data "aws_caller_identity" "current" {}

# --- AWS CodeBuild Project ---
# This is the core resource. It defines a CodeBuild project that will act as our
# managed GitHub Actions runner.
resource "aws_codebuild_project" "github_actions_runner" {
  name          = var.project_name
  description   = "Managed GitHub Actions runner on AWS CodeBuild"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "60" # In minutes

  # Source configuration: Connects to your GitHub repository.
  # This uses the OAuth connection method, which requires manual setup in the console first.
  source {
    type                = "GITHUB"
    location            = var.github_repo_url
    git_clone_depth     = 1
    report_build_status = true # Reports status back to GitHub PRs/commits
  }

  # Environment configuration: Defines the runner's environment.
  # We use a standard Amazon Linux 2 image.
  # Privileged mode is required for Docker-in-Docker if you run containerized jobs.
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL" # Choose size as needed
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  # VPC configuration: Places the runner in a specific VPC.
  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  # Artifacts configuration: Not needed for this runner setup.
  artifacts {
    type = "NO_ARTIFACTS"
  }

  # Logs configuration: Sends build logs to CloudWatch.
  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/${var.project_name}"
      stream_name = "runner-logs"
    }
  }

  tags = {
    Project = var.project_name
    Purpose = "GitHub-Actions-Runner"
  }
}
