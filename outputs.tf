# --- Outputs ---
# Provides useful information after Terraform applies the configuration.
output "codebuild_project_name" {
  description = "The name of the AWS CodeBuild project."
  value       = aws_codebuild_project.github_actions_runner.name
}

output "codebuild_role_arn" {
  description = "The ARN of the IAM role for the CodeBuild project."
  value       = aws_iam_role.codebuild_role.arn
}

output "secrets_manager_secret_name" {
  description = "The name of the secret where the GitHub PAT should be stored."
  value       = aws_secretsmanager_secret.github_pat.name
}
