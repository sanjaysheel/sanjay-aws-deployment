# sanjay-aws-deployment
Got it! Here's a **documentation-style** README for setting up GitHub Actions for deploying Terraform into AWS. This is intended to provide clear, concise instructions that users can follow to set up and understand the process.

---

# Terraform Deployment with GitHub Actions

This repository provides a setup for deploying infrastructure to AWS using **Terraform** and **GitHub Actions**. The process includes automatic and manual deployment to multiple environments such as **development**, **staging**, and **production**.

---

## Table of Contents

* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Setup Instructions](#setup-instructions)

  * [1. AWS Setup](#1-aws-setup)
  * [2. Terraform Setup](#2-terraform-setup)
  * [3. GitHub Secrets Setup](#3-github-secrets-setup)
  * [4. Workflow Configuration](#4-workflow-configuration)
  * [5. Triggering Deployments](#5-triggering-deployments)
* [Branch Configuration](#branch-configuration)
* [Best Practices](#best-practices)
* [Troubleshooting](#troubleshooting)

---

## Overview

This setup uses **GitHub Actions** to automate the deployment of infrastructure to **AWS** using **Terraform**. It provides flexibility to deploy to different environments (e.g., `dev`, `stag`, `prod`) within the same AWS account. The workflow can be triggered automatically on `push` or `pull_request`, and it also supports manual triggering via the GitHub Actions UI.

### Key Features:

* **Automatic deployment** on push and pull requests.
* **Manual deployment** using `workflow_dispatch`.
* **Environment isolation** using Terraform workspaces (`dev`, `stag`, `prod`).
* **Secure AWS credentials** via GitHub Secrets.
* **Customizable workflow** to run Terraform commands like `init`, `plan`, `apply`, and `destroy`.

---

## Prerequisites

Before setting up the GitHub Actions workflow, ensure you have:

* An **AWS account** with the appropriate IAM permissions to manage resources using Terraform.
* **Terraform** installed on your local machine (optional for local testing).
* An active **GitHub repository** to store and manage the workflow files.
* AWS **Access Key ID** and **Secret Access Key** stored as GitHub Secrets.

---

## Setup Instructions

### 1. AWS Setup

You need to set up AWS credentials for GitHub Actions to authenticate and deploy resources.

1. **Create an IAM User in AWS**:

   * Go to **IAM > Users** in the AWS Management Console.
   * Create a new user with programmatic access and the necessary permissions for Terraform (e.g., `AdministratorAccess` or a more restrictive set based on your needs).

2. **Store AWS Credentials in GitHub Secrets**:

   * Go to your GitHub repository **Settings > Secrets**.
   * Add the following secrets:

     * `AWS_ACCESS_KEY_ID`: Your IAM user’s access key ID.
     * `AWS_SECRET_ACCESS_KEY`: Your IAM user’s secret access key.
     * `AWS_REGION`: The AWS region where you want to deploy (e.g., `us-east-1`).

---

### 2. Terraform Setup

1. **Configure Your Terraform Files**:

   * Add your Terraform configuration files (`main.tf`, `variables.tf`, etc.) to the repository.
   * Ensure that your Terraform configuration uses workspaces for environment isolation:

     ```hcl
     terraform {
       backend "s3" {
         bucket = "your-terraform-state-bucket"
         key    = "state/${terraform.workspace}/terraform.tfstate"
         region = "us-east-1"
       }
     }
     ```
   * Use a `.tfvars` file to define environment-specific variables:

     * `dev.tfvars`, `prod.tfvars`, etc.

2. **Initialize Terraform Locally (Optional)**:

   * Run `terraform init` locally to ensure that all required providers are downloaded.
   * This step is not necessary for GitHub Actions as it will automatically run `terraform init` on each workflow execution.

---

### 3. GitHub Secrets Setup

In your GitHub repository:

1. Go to **Settings > Secrets**.
2. Add the following secrets:

   * `AWS_ACCESS_KEY_ID`
   * `AWS_SECRET_ACCESS_KEY`
   * `AWS_REGION`

These secrets are required for AWS authentication and deployment in GitHub Actions.

---

### 4. Workflow Configuration

1. **Create the GitHub Actions Workflow**:

   * In the root of your repository, create a folder `.github/workflows/`.
   * Inside this folder, create a workflow file, e.g., `terraform.yml`.

2. **Sample Workflow File** (`.github/workflows/terraform.yml`):

   ```yaml
   name: Terraform AWS Deployment

   on:
     push:
       branches:
         - '**'  # Trigger on any push to any branch
     pull_request:
       branches:
         - '**'  # Trigger on any pull request to any branch
     workflow_dispatch:
       inputs:
         environment:
           description: 'Choose your environment'
           required: true
           default: 'development'
           type: choice
           options:
             - development
             - staging
             - production
         terraform_action:
           description: 'Select Terraform action'
           required: true
           default: 'apply'
           type: choice
           options:
             - init
             - plan
             - apply
             - destroy

   jobs:
     terraform:
       runs-on: ubuntu-latest

       steps:
         - name: Checkout Code
           uses: actions/checkout@v2

         - name: Set up Terraform
           uses: hashicorp/setup-terraform@v1
           with:
             terraform_version: '1.4.0'

         - name: Configure AWS credentials
           uses: aws-actions/configure-aws-credentials@v1
           with:
             aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
             aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
             aws-region: ${{ secrets.AWS_REGION }}

         - name: Initialize Terraform
           run: terraform init

         - name: Apply Terraform
           if: ${{ github.event.inputs.terraform_action == 'apply' }}
           run: terraform apply -auto-approve
   ```

This file defines the steps to:

* Checkout the code.
* Set up Terraform.
* Configure AWS credentials.
* Run `terraform init`, `plan`, and `apply` based on the user input.

---

### 5. Triggering Deployments

You can trigger the deployment workflow both **automatically** and **manually**:

1. **Automatic Triggering**:

   * The workflow is automatically triggered on **push** or **pull request** events for **any branch**.
2. **Manual Triggering**:

   * Navigate to the **Actions** tab of your GitHub repository.
   * Select the workflow you want to run (e.g., `Terraform AWS Deployment`).
   * Click **Run workflow**.
   * Choose the environment (e.g., `development`, `production`, etc.) and the Terraform action (`init`, `plan`, `apply`, or `destroy`).
   * Click **Run workflow** to trigger the deployment.

---

## Branch Configuration

To ensure that the workflow is available for all branches:

1. **Merge the Workflow into All Branches**:

   * If the workflow file is initially only in `main`, ensure it's merged into any other branches where you want to trigger the workflow.
   * Use the following command to merge the workflow into other branches:

     ```bash
     git checkout <branch_name>
     git merge main  # Merge workflow file from the main branch
     git push origin <branch_name>
     ```

2. **Automatic Deployment**:

   * The workflow will automatically run for any branch on `push` or `pull_request` events, as defined in the workflow trigger section.

---

## Best Practices

* **Isolate State**: Use Terraform workspaces to isolate environments (e.g., `dev`, `stag`, `prod`).
* **Use Remote State**: Always store your Terraform state in a remote backend (e.g., S3 with DynamoDB for state locking).
* **Secure Secrets**: Never hardcode sensitive data in your workflow files. Always use GitHub Secrets for credentials and sensitive information.

---

## Troubleshooting

* **Workflow Not Triggering**: Ensure that the `.github/workflows/terraform.yml` file exists in the branch you’re trying to deploy from.
* **AWS Credentials Issue**: Double-check that `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` are properly set in GitHub Secrets.
* **Terraform Workspace Issues**: Ensure that the correct workspace is selected before running Terraform commands.

---

### Conclusion

This setup provides a robust mechanism for automating Terraform deployments to AWS using GitHub Actions. It supports both automatic deployments (on `push` and `pull_request`) and manual deployments via the GitHub UI. By using Terraform workspaces and remote state management, each environment remains isolated and secure.

For any further assistance, feel free to reach out or consult the [GitHub Actions documentation](https://docs.github.com/en/actions).

---

This README provides clear documentation for setting up, configuring, and using the GitHub Actions workflow for deploying Terraform to AWS. Let me know if you need additional changes!
