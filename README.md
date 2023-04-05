# Creating-a-Basic-CI-CD-Workflow-with-GitHub-Actions
Creating a Basic CI/CD Workflow with GitHub Actions

This week, I had the pleasure of exploring GitHub actions to automate a Terraform deployment to the AWS cloud. The focus of this article is to briefly walk through how I used GitHub actions to automate the deployment of a simple S3 bucket via Terraform. You may be thinking, why go through the hassle when you can deploy this in a few easy steps locally? This is a great question. My first response is that you need a central place to work on your code for collaboration and versioning purposes when working on large-scale projects. My second response is that we need a way to streamline the deployment (e.g., Terraform write, plan, apply) and perhaps introduce an approval stage to avoid deploying code without a review from a lead engineer.

GitHub Actions is a CI/CD platform that allows you to automate your build, test, and deployment pipelines based on triggered events in your GitHub repository. The workflow file is defined using YAML and located within the .github/workflows directory. Every workflow has one or more jobs, and each job runs inside its own virtual machine or container (also known as “runners”) running Windows, Linux, or MacOS. Please visit the official documentation link below for more information on GitHub Actions.


