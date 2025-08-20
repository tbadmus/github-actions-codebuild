# Github-actions-codebuild

Here is the Terraform code and a step-by-step guide to automate your CI/CD pipeline using GitHub Actions with AWS CodeBuild as a managed runner. This setup allows you to run your GitHub Actions workflows on your own secure and customizable infrastructure within AWS.

# Step-by-Step Deployment Guide

#### Step 1: Prerequisites

Before you begin, make sure you have the following:

1. AWS Account: An active AWS account with permissions to create IAM roles, CodeBuild projects, and Secrets Manager secrets.
2. GitHub Account: A GitHub account and a repository where you want to set up the workflow.
3. Terraform Installed: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your local machine.
4. AWS CLI Installed: [Install and configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with your credentials.

#### Step 2: AWS Setup

1. Create an S3 Bucket for Terraform State: Terraform needs a place to store its state file. Create a unique S3 bucket for this purpose.
2. Generate a GitHub Personal Access Token (PAT):

* Go to your GitHub **Settings** > **Developer settings** > **Personal access tokens** >  **Tokens (classic)** .
* Click  **Generate new token** .
* Give it a descriptive name.
* Set the expiration.
* Select the following scopes:

  * `repo` (Full control of private repositories)
  * `admin:org` (if it's an organization repository, to read and write repository and organization projects)
* Click **Generate token** and  **copy the token immediately** . You will not see it again.

  3.**Store the GitHub PAT in AWS Secrets Manager** :
* The Terraform code creates a secret placeholder. You need to manually add the PAT value to it.
* Navigate to the **AWS Secrets Manager** console.
* Find the secret named `github-actions-pat` (or the name you defined in `variables.tf`).
* Click on the secret, then click  **Retrieve secret value** .
* Click  **Edit** , and paste your GitHub PAT into the secret value field. Save the changes.

#### Step 3: Deploying the Infrastructure

1. Initialize Terraform
2. Review the Plan
3. Apply the Configuration: If the plan looks correct, apply it.

This will provision the CodeBuild project, IAM roles, and all other necessary resources.

#### Step 4: Connect CodeBuild to GitHub

This is a one-time manual step to authorize CodeBuild to access your GitHub account.

1. Go to the AWS CodeBuild console.
2. Select the project created by Terraform (e.g., github-runner).
3. Go to the Edit > Source section.
4. Under "Source provider," it should say "GitHub." Click the Connect using OAuth button (if it's not already connected).
5. A pop-up will appear, asking you to authorize AWS CodeBuild. Authorize it. If you have already authorized it for other projects, you may just need to select your PAT from the dropdown.

#### Step 5: Create the GitHub Actions Workflow

Finally, create a workflow file in your GitHub repository to use the new runner.

1. In your repository, create a directory `.github/workflows/`
2. Inside that directory, create a file named `main.yml`:

```
# .github/workflows/main.yml
name: AWS CodeBuild CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    # This is the key part: it tells the job to run on your custom runner.
    # The labels 'self-hosted' and the CodeBuild project name are used to select the correct runner.
    runs-on: [self-hosted, linux, x64, "${{ vars.AWS_CODEBUILD_PROJECT_NAME }}"]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Run a one-line script
      run: echo Hello from AWS CodeBuild!

    - name: Run a multi-line script
      run: |
        echo Add other build steps here.
        ls -la
        # For example, if you have a Node.js project:
        # npm install
        # npm test
```

3. Add a Repository Variable:

* In your GitHub repo, go to Settings > Secrets and variables > Actions.
* Click the Variables tab.
* Create a New repository variable named `AWS_CODEBUILD_PROJECT_NAME` and set its value to `github-runner` (or the project name you used). This allows your YAML file to be dynamic.

#### Step 6: Trigger and Verify

* Commit and push the (.github/workflows/main.yml) file to your repository's `main` branch.
* Go to the Actions tab in your GitHub repository.
* You should see the workflow running. Click on it.
* In the job logs, you'll see that it's waiting for a runner. Shortly after, the AWS CodeBuild project will start, execute the steps, and send the logs back to GitHub.

You have now successfully integrated GitHub Actions with a managed AWS CodeBuild runner!
