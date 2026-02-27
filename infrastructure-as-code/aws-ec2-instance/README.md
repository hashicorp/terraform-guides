# Provision an EC2 instance in AWS
This Terraform configuration provisions an EC2 instance in AWS.

## Details
By default, this configuration provisions a Ubuntu 14.04 Base Image AMI (with ID ami-2e1ef954) with type t2.micro in the us-east-1 region. The AMI ID, region, and type can all be set as variables. You can also set the name variable to determine the value set for the Name tag.

Note that you need to set environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.

## Step-by-Step Execution

1. **Install Terraform**: Ensure that Terraform is installed on your machine. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).

2. **Clone the Repository**: Clone this repository to your local machine.
    ```sh
    git clone https://github.com/hashicorp/terraform-guides.git
    cd terraform-guides/infrastructure-as-code/aws-ec2-instance
    ```

3. **Set AWS Credentials**: You can either set your AWS credentials as environment variables or configure AWS CLI on your system.

    **Option 1: Set environment variables**
    ```sh
    export AWS_ACCESS_KEY_ID=your_access_key_id
    export AWS_SECRET_ACCESS_KEY=your_secret_access_key
    ```

    **Option 2: Configure AWS CLI**
    ```sh
    aws configure
    ```

4. **Initialize Terraform**: Initialize the Terraform configuration.
    ```sh
    terraform init
    ```

5. **Plan the Infrastructure**: Generate and review the execution plan.
    ```sh
    terraform plan
    ```

6. **Apply the Configuration**: Apply the Terraform configuration to provision the EC2 instance.
    ```sh
    terraform apply
    ```

7. **Verify the Instance**: After the apply command completes, you can verify the instance in the AWS Management Console.

8. **Destroy the Infrastructure**: When you no longer need the instance, you can destroy the infrastructure.
    ```sh
    terraform destroy
    ```

Make sure to replace `your_access_key_id` and `your_secret_access_key` with your actual AWS credentials.
