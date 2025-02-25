# Terraform: S3 Bucket and Lambda Function Integration

This repository contains Terraform code to create an S3 bucket and a Lambda function. The Lambda function is triggered automatically whenever a new file is uploaded to the S3 bucket. This setup is useful for processing files (e.g., logs, images, or data) as soon as they are uploaded to the bucket.

## Overview

The Terraform code performs the following tasks:
1. Creates an S3 bucket.
2. Creates a Lambda function.
3. Configures the Lambda function to be triggered by `s3:ObjectCreated:*` events in the S3 bucket.
4. Sets up the necessary IAM roles and permissions for the Lambda function to access the S3 bucket.

## Prerequisites

Before using this Terraform code, ensure you have the following:
- **AWS Account**: You need an AWS account to create the resources.
- **Terraform Installed**: Install Terraform on your local machine. You can download it from [here](https://www.terraform.io/downloads.html).
- **AWS CLI Configured**: Ensure your AWS CLI is configured with the necessary credentials. Run `aws configure` to set up your credentials.

## Terraform Code Structure

The Terraform code is divided into two main parts:
1. **Lambda Function Configuration**:
   - Creates an IAM role for the Lambda function.
   - Packages the Lambda function code into a ZIP file.
   - Deploys the Lambda function and grants it permission to be invoked by the S3 bucket.

2. **S3 Bucket Configuration**:
   - Creates an S3 bucket.
   - Configures the bucket to send notifications to the Lambda function when new files are uploaded.

### Key Files
- `main.tf`: Contains the main Terraform configuration for the Lambda function and S3 bucket.
- `lambda.py`: The Python code for the Lambda function (located in the `code/` directory).
- `lambda_function_payload.zip`: The packaged Lambda function code (generated by Terraform).

## How It Works

1. **S3 Bucket Creation**:
   - The S3 bucket is created with the name `mupando-lambda-s3-bucket-03022025`.
   - The bucket is configured to be publicly readable (ACL = `public-read`).

2. **Lambda Function Creation**:
   - The Lambda function is created using the `lambda.py` file as the source code.
   - The function is configured to use the Python 3.9 runtime.
   - An IAM role is created to allow the Lambda function to assume the necessary permissions.

3. **S3 Trigger Configuration**:
   - The S3 bucket is configured to send notifications to the Lambda function whenever a new file is uploaded.
   - The Lambda function is triggered only for files with the prefix `AWSLogs/` and the suffix `.log`.

## Usage

### Steps to Deploy

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/terraform-s3-lambda.git
   cd terraform-s3-lambda
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the Terraform plan:
   ```bash
   terraform plan
   ```

4. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

5. Confirm the deployment by typing `yes` when prompted.

### Testing the Setup

1. Upload a file to the S3 bucket:
   ```bash
   aws s3 cp test.log s3://mupando-lambda-s3-bucket-03022025/AWSLogs/
   ```

2. Check the Lambda function logs in CloudWatch to verify that the function was triggered.

### Cleaning Up

To destroy the resources created by Terraform:
```bash
terraform destroy
```

## Terraform Code Snippets

### IAM Role for Lambda
```hcl
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam-for-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
```

### Lambda Function
```hcl
resource "aws_lambda_function" "foo" {
  filename      = "code/lambda_function_payload.zip"
  function_name = "mupandoflix"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      foo = "bar"
    }
  }
}
```

### S3 Bucket and Trigger
```hcl
resource "aws_s3_bucket" "foo" {
  bucket        = "mupando-lambda-s3-bucket-03022025"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.foo.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.foo.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
