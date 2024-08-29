data "aws_iam_policy_document" "lambda_assume" {
    statement {
        actions = [
            "sts:Assume"
        ]

        effect = "Allow"

        principals {
          type = "Service"
          identifiers = [
            "lambda.amazonaws.com"
          ]
        }
    }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}