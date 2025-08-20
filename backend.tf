  # This bucket must be created manually before you run terraform apply.
  terraform {
    backend "s3" {
        bucket = "elbee-backend-tf"
        key    = "github-actions/codebuild-runner/terraform.tfstate"
        region = "us-east-1" # Specify your desired AWS region
    }
  }

