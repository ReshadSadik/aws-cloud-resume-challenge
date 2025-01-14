data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda_function.zip"
}


resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}


resource "aws_iam_policy" "lambda_basic_execution_policy" {
  name        = "lambda-basic-execution-policy"
  description = "Basic execution policy for lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource   = "arn:aws:logs:*:*:*"
        Effect     = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_basic_execution_policy.arn
}



resource "aws_lambda_function" "example_lambda" {
  function_name    = "getViewCounts_resume" # Give your Lambda function a name
  handler          = "func.lambda_handler" # The handler within your Python file
  runtime          = "python3.9"  # Or your desired runtime, check https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html
  memory_size      = 128 # Memory allocated in MB
  timeout          = 30 # Timeout in seconds
  role             = aws_iam_role.lambda_execution_role.arn # Reference the IAM role
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

