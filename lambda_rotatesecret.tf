data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/rotate_secret"
  output_path = "${path.module}/rotate_secret.zip"
}

resource "aws_lambda_function" "rotate_secret" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "rotate_secret"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
}

resource "aws_secretsmanager_secret_rotation" "rds_secret_rotation" {
  secret_id     = data.aws_secretsmanager_secret.rds_secret.id
  rotation_lambda_arn = aws_lambda_function.rotate_secret.arn
  rotation_rules {
    automatically_after_days = 1
  }
}