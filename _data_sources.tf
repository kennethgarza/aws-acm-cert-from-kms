data "aws_secretsmanager_secret" "rds_secret" {
  name = "sqlserver_admin"
}

