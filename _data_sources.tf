data "aws_secretsmanager_secret" "rds_secret" {
  name = "sqlserver_admin"
}

data "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

