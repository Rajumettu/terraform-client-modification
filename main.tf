variable "iam_user_name" {
  default     = "<>"
}
data "aws_iam_user" "existing_user" {
  user_name = "var.iam_user_name"  
}

resource "aws_iam_policy" "api_key_rotation_policy" {
  name        = "APIKeyRotationPolicy"
  description = "Denies access if API keys are not rotated within 90 days"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Deny",
      Action   = [
        "iam:UpdateAccessKey",
        "iam:DeleteAccessKey",
        "iam:CreateAccessKey"
      ],
      Resource = "*",
      Condition = {
        NumericGreaterThanEquals = {
          "aws:CredentialPresentTime" : "90"
        }
      }
    }]
  })
}

# AWS Lambda function to check for access key rotation
resource "aws_lambda_function" "check_access_key_rotation" {
  filename      = "check_access_key_rotation.zip" # Path to your lambda function code
  function_name = "CheckAccessKeyRotation"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
}

# CloudWatch Events rule to trigger the Lambda function periodically
resource "aws_cloudwatch_event_rule" "trigger_check_access_key_rotation" {
  name                = "TriggerCheckAccessKeyRotation"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "invoke_check_access_key_rotation" {
  rule = aws_cloudwatch_event_rule.trigger_check_access_key_rotation.name
  arn  = aws_lambda_function.check_access_key_rotation.arn
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "LambdaExecutionRole"
  }
}

# Attach the IAM policy to the appropriate IAM users or roles
# Replace <your_user_or_role_here> with the appropriate user or role ARN
resource "aws_iam_policy_attachment" "attach_policy_to_user" {
  name       = "AttachPolicyToUser"
  users      = data.aws_iam_user.user_name
  policy_arn = aws_iam_policy.api_key_rotation_policy.arn
}
