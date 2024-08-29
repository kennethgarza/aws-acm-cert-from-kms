resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [
    aws_subnet.main.id
  ]
}

resource "aws_db_instance" "sql_server" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "sqlserver-se"
  engine_version       = "15.00.4073.23.v1"  # SQL Server 2019
  identifier           = "test-instance"
  instance_class       = "db.t2.micro"
  username             = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
  parameter_group_name = "default.sqlserver-se-15.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]
  db_subnet_group_name = aws_db_subnet_group.main.name

timeouts {
    create = "15m"
    delete = "15m"
    update = "15m"
  }
}
