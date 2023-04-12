# Creating-a-Basic-CI-CD-Workflow-with-GitHub-Actions
Creating a Basic CI/CD Workflow with GitHub Actions

This week, I had the pleasure of exploring GitHub actions to automate a Terraform deployment to the AWS cloud. The focus of this article is to briefly walk through how I used GitHub actions to automate the deployment of a simple S3 bucket via Terraform. You may be thinking, why go through the hassle when you can deploy this in a few easy steps locally? This is a great question. My first response is that you need a central place to work on your code for collaboration and versioning purposes when working on large-scale projects. My second response is that we need a way to streamline the deployment (e.g., Terraform write, plan, apply) and perhaps introduce an approval stage to avoid deploying code without a review from a lead engineer.

GitHub Actions is a CI/CD platform that allows you to automate your build, test, and deployment pipelines based on triggered events in your GitHub repository. The workflow file is defined using YAML and located within the .github/workflows directory. Every workflow has one or more jobs, and each job runs inside its own virtual machine or container (also known as “runners”) running Windows, Linux, or MacOS. Please visit the official documentation link below for more information on GitHub Actions.


Objectives:

Create an AWS S3 bucket and DynamoDB table to store Terraform's backend state and dependency lock life.

Create a Staging and Production environment with a required manual approval stage in a new GitHub repository.

Add AWS secret and access key credentials to GitHub secrets.

Write and commit Terraform code that will deploy a new AWS S3 bucket.

Create a GitHub Actions Workflow file in YAML.

Confirm Build job executes successfully in your Staging environment.

Approve deployment to your Production environment.



Prerequisites:


Basic GitHub/AWS/Terraform Knowledge

GitHub account

AWS account with Administrator Access permissions

AWS CLI installed and configured with your programmatic access credentials on your local terminal


Step 1: Create an AWS S3 bucket and DynamoDB table to store Terraform’s backend state and dependency lock life

Before we create and configure our GitHub repository and write our terraform code. We must configure an S3 bucket to centrally host our Terraform backend state and a DynamoDB table to handle our dependency lock file. The backend state is responsible for keeping track of the resources Terraform manages. The dependency lock file locks the state file when configuration changes occur. This keeps multiple users from manipulating the backend state during a configuration push, which can ultimately lead to corruption. Refer to the official documentation links below for more information on backend states and the dependency lock files.

Create an S3 bucket for the backend state:

<img width="728" alt="Screenshot 2023-04-12 at 18 12 50" src="https://user-images.githubusercontent.com/67044030/231543490-1c2447ab-e978-4501-bc52-311a56910691.png">

<img width="898" alt="Screenshot 2023-04-12 at 18 13 58" src="https://user-images.githubusercontent.com/67044030/231543693-dbd60390-265d-4811-9a3e-28b9d2528b93.png">


Create a DynamoDB table for the dependency lock file:

<img width="721" alt="Screenshot 2023-04-12 at 18 15 15" src="https://user-images.githubusercontent.com/67044030/231544024-27dd2911-c994-4619-9f69-ad65da578f26.png">

<img width="668" alt="Screenshot 2023-04-12 at 18 15 26" src="https://user-images.githubusercontent.com/67044030/231544412-aa66fdd8-815d-4a0f-96fb-9a801fcbc2ed.png">

<img width="922" alt="Screenshot 2023-04-12 at 18 17 06" src="https://user-images.githubusercontent.com/67044030/231544645-75d9c909-6a8d-4554-8b34-2af4ff3e4c70.png">


Step 2: Create a Staging and Production environment with a required manual approval stage in a new GitHub repository
In this step, we will create a new GitHub repository and the required Staging and Production environments to simulate a required manual approval stage.

Log into GitHub and create a new repository:

After you have specified a repository name and the Terraform .gitignore template, as seen in the screenshot above, scroll down to the bottom of the page and select “Create Repository”.

<img width="936" alt="Screenshot 2023-04-12 at 18 18 13" src="https://user-images.githubusercontent.com/67044030/231544982-13b1a18a-bcdf-4495-a081-32606fd788b6.png">

<img width="1070" alt="Screenshot 2023-04-12 at 18 18 33" src="https://user-images.githubusercontent.com/67044030/231545161-3f55c2cc-70c6-42b5-a6ca-79f92e56aac7.png">


Now, we will navigate to “Settings” >>> “Environments”.

<img width="1235" alt="Screenshot 2023-04-12 at 18 19 15" src="https://user-images.githubusercontent.com/67044030/231545776-ea98eec8-ea7f-4138-a3bc-8735cb7b5502.png">



Create two environments, “Staging” and “Production”.

<img width="893" alt="Screenshot 2023-04-12 at 18 21 08" src="https://user-images.githubusercontent.com/67044030/231546026-06517efe-3d2d-4425-a530-899217ee0902.png">


Don’t make any changes to the Staging environment and go back to the Environments section.

<img width="1156" alt="Screenshot 2023-04-12 at 18 22 09" src="https://user-images.githubusercontent.com/67044030/231546289-7291e439-a975-480d-9edf-6252a7ed86d9.png">



Add yourself as a required reviewer in the Production environment and select “Save protection rules”.

<img width="810" alt="Screenshot 2023-04-12 at 18 23 28" src="https://user-images.githubusercontent.com/67044030/231546530-158d0bcd-f3b1-4b7a-82a8-a7cf65571f99.png">


Step 3: Add AWS secret and access key credentials to GitHub secrets

For our GitHub Actions workflow runners (virtual machines/containers) to deploy resources on our behalf to AWS, we must configure the GitHub repository with AWS access and secret key credentials. We will use GitHub secrets to ensure that these sensitive materials aren’t in plain text.

Settings >>> Secrets >>> Actions

<img width="1251" alt="Screenshot 2023-04-12 at 18 24 51" src="https://user-images.githubusercontent.com/67044030/231547020-9b251700-2fd3-4ec0-b700-424eb1e4e4c2.png">



Next, we will create the following secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_REGION.

NOTE: Your AWS_REGION doesn’t have to be a secret, but from a security perspective, we will treat the deployment region as sensitive data.

Select “New repository secret” >>> Enter your values >>> Select “Add secret”


<img width="863" alt="Screenshot 2023-04-12 at 18 31 48" src="https://user-images.githubusercontent.com/67044030/231547352-c519be99-dfc5-4173-9ad8-55775167117c.png">


Repeat this step for the AWS_SECRET_ACCESS_KEY and AWS_REGION secret variables.

The final product should look like this.



NOTE: You must confirm that the AWS Access and Secret keys you provide have the necessary permissions to access the S3 backend state bucket and DynamoDB lock table and the permission to deploy the new S3 bucket.

Step 4: Write and commit Terraform code that will deploy a new AWS S3 bucket
In this step, we are going to create a basic main.tf that will deploy a S3 bucket using Terraform.

Create main.tf file.


For <Backend State S3 Bucket Name> enter the S3 bucket name you have chosen to host your Terraform backend state file.
For <Dependency Lock DynamoDB Table Name> enter the DynamoDB table name specified earlier.
For <Terraform S3 Bucket Name> enter a unique name for the new S3 bucket you will be deploying using Terraform and GitHub Actions.
  
  
  
Step 5: Create GitHub Actions YAML file

To create our GitHub Actions YAML file, we must navigate to the Actions section of the GitHub repository.

Actions >>> Select “set up a workflow yourself”

<img width="1036" alt="Screenshot 2023-04-12 at 18 37 37" src="https://user-images.githubusercontent.com/67044030/231547778-1fa8b3d0-c8bc-4268-b214-99b36992a5f1.png">
  
  
NOTE: on line 5, where it says “branches: [master]”, you may have to change the branch name to main or whatever you used to name your default main branch.

Once you are done entering the code above, commit the change.

<img width="1222" alt="Screenshot 2023-04-12 at 18 39 28" src="https://user-images.githubusercontent.com/67044030/231548223-df358a53-3223-4f01-b84f-70939aae9d55.png">
 
 <img width="1244" alt="Screenshot 2023-04-12 at 18 40 33" src="https://user-images.githubusercontent.com/67044030/231548860-54266ba1-aad3-4e15-871c-3a610f9b3bee.png">
 
 <img width="1237" alt="Screenshot 2023-04-12 at 18 41 56" src="https://user-images.githubusercontent.com/67044030/231549364-06e71280-5457-4a00-98fd-234afc6a6f45.png">
  
Step 6: Confirm Build job executes successfully in your Staging environment and approve deployment to your Production environment

<img width="1254" alt="Screenshot 2023-04-12 at 18 42 57" src="https://user-images.githubusercontent.com/67044030/231549671-466e2f88-68f6-40fd-b6bd-3e7079c92678.png">

<img width="915" alt="Screenshot 2023-04-12 at 18 43 26" src="https://user-images.githubusercontent.com/67044030/231549921-c3059387-9061-4275-988d-27eb26485911.png">
  
To review our workflow jobs' status, head back to the Action section in GitHub.
  
  
As we can see, the workflow is in a “waiting” status because manual approval is required from the reviewer. Click on “Create main.yml” and then select the Build job to view additional details.

Here we can view details on all the steps performed in the Build job.

<img width="887" alt="Screenshot 2023-04-12 at 18 44 34" src="https://user-images.githubusercontent.com/67044030/231550265-de41837b-9b4b-4284-81a0-50edd9e2664c.png">
  
  
 If you look at the Terraform plan step, you will see the exact details you would if you executed the command locally in your terminal.
  
 Navigate to the GitHub Action/Create main.yml page and select “Review deployments”
  
 Since we are the reviewer, we can review and approve the deployment. We also have the option to leave additional comments and/or reject the deployment.
 
 <img width="1241" alt="Screenshot 2023-04-12 at 18 45 32" src="https://user-images.githubusercontent.com/67044030/231550683-a4e14a7d-1948-480b-bcb4-161e7d0d66c0.png">
  
  
 After a few moments, you should receive a success status message.
 
 <img width="1238" alt="Screenshot 2023-04-12 at 18 46 22" src="https://user-images.githubusercontent.com/67044030/231551008-20e3b4fc-cb92-444f-afd5-2be31185b7d2.png">

From here, you can review the Deploy build details or head to the AWS management console to verify that your S3 bucket deployed successfully.

<img width="920" alt="Screenshot 2023-04-12 at 18 47 09" src="https://user-images.githubusercontent.com/67044030/231551233-759e97f9-5f49-4344-a4c0-526c3bffd793.png">

<img width="1242" alt="Screenshot 2023-04-12 at 18 48 48" src="https://user-images.githubusercontent.com/67044030/231551474-ebdf0d9c-ef24-440a-bc0c-8c14ad92f63a.png">


Bonus Step: Make a change to Terraform code and verify GitHub Actions workflow is triggered as expected
  
Navigate to Code >>> main.tf >>> Edit the file
  
Change the code to the following:

Note: We are adding a tag to the AWS S3 bucket resource.

Once complete, commit the change.

Head back over to the Actions section, select “Update main.tf”, and review the workflow status.
  
  
Similar to our previous commit, our Build job was successful, and we are waiting for approval to release the change into the Production environment.

Select “Review deployments” and approve.
  
After a few moments, we will see that the Deploy job was successful.
  
  
If we go to our AWS management console, we can verify the tags were configured successfully.

Step 8: Clean Up
  
Delete the GitHub repository.

<img width="1372" alt="Screenshot 2023-04-12 at 18 50 02" src="https://user-images.githubusercontent.com/67044030/231551793-a91d4844-6cb2-4dcc-bd3d-c878793dd828.png">

<img width="1253" alt="Screenshot 2023-04-12 at 18 50 51" src="https://user-images.githubusercontent.com/67044030/231552016-18624e8e-4a7a-4a0a-bf78-e519db02f04e.png">
  
Delete the two S3 buckets and DynamoDB table in the AWS console or use these commands in your local terminal.

Delete the S3 buckets.
  
  
aws s3 rb s3://<bucket_name> --force

<img width="756" alt="Screenshot 2023-04-12 at 18 52 47" src="https://user-images.githubusercontent.com/67044030/231552304-6f2c6063-ce78-49c2-a9a4-f7c88225d79b.png">

<img width="750" alt="Screenshot 2023-04-12 at 18 53 18" src="https://user-images.githubusercontent.com/67044030/231552543-0e7f7af9-41d7-4f52-b853-5c902bb1fd32.png">

<img width="860" alt="Screenshot 2023-04-12 at 18 53 35" src="https://user-images.githubusercontent.com/67044030/231553589-e2e4a89d-2243-4484-816a-4080040dd608.png">

Delete the DynamoDB table.

aws dynamodb delete-table --table-name <table_name>

<img width="728" alt="Screenshot 2023-04-12 at 19 36 20" src="https://user-images.githubusercontent.com/67044030/231553219-54dc3e69-7522-4635-84cc-d13424e6ba4e.png">

Settings >> Scroll Down >> Select “Delete this repository”
