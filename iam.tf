# --- IAM Roles and Policies ---
# Defines the necessary permissions for AWS CodeBuild to operate.

# 1. CodeBuild Service Role
# This role is assumed by the CodeBuild project.
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-service-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# 2. CodeBuild Service Policy
# This policy grants the CodeBuild role permissions to:
# - Write logs to CloudWatch.
# - Access the GitHub PAT from Secrets Manager.
# - Interact with the GitHub repository (source).
# - Create network interfaces for VPC access (if needed).
resource "aws_iam_policy" "codebuild_policy" {
  name   = "${var.project_name}-codebuild-service-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}:*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.github_pat.arn
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:StopBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:ListBuildsForProject"
        ],
        Resource = aws_codebuild_project.github_actions_runner.arn
      },
      # Required for CodeBuild to interact with GitHub
      {
        Effect   = "Allow",
        Action   = "ssm:GetParameters",
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/CodeBuild/GitHub-*"
      }
    ]
  })
}

# 3. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}
