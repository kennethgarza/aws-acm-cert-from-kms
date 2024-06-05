### MASTER DB PASSWORD ###
# resource "aws_kms_key" "secrets_key" {
#   description = "kms key for secrets"
# }

# resource "aws_secretsmanager_secret" "masterSecret" {
#   name = "prod/credentials/octopus/master"
#   kms_key_id = aws_kms_key.secrets_key.arn 
# }

# ## password for master
# resource "random_string" "masterPassword" {
#   length = 16
#   special = true
#   override_special = "/@£$"

#     lifecycle {
#     ignore_changes = [
#       length,
#       special,
#       override_special
#     ]
#   }
# }

# output "masterPassword" {
#   value = random_string.masterPassword.result
# }

# resource "aws_secretsmanager_secret_version" "masterSecret" {
#   secret_id = aws_secretsmanager_secret.masterSecret.id
#   secret_string = random_string.masterPassword.result
# }

## vpc setup
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_b" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
}


## rds setup
resource "aws_kms_key" "sqlserver" {
  description = "kms key for sql server"
}

resource "aws_db_subnet_group" "sqlserver" {
  name       = "sqlserver"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_db_instance" "sqlserver" {
  allocated_storage           = 20
  auto_minor_version_upgrade  = false                                  
  custom_iam_instance_profile = "AWSRDSCustomSQLServerInstanceProfile" 
  backup_retention_period     = 7
  db_subnet_group_name        = aws_db_subnet_group.sqlserver.name 
  engine                      = "sqlserver-se"
  engine_version              = "15.00.4249.2.v1"
  identifier                  = "rotation-test"
  instance_class              = "db.r5.xlarge"
  kms_key_id                  = aws_kms_key.sqlserver.arn
  multi_az                    = false
  username                    = "master"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.sqlserver.key_id
  storage_encrypted           = true

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}

