resource "aws_secretsmanager_secret" "db_secrets" {
  name = "db_secrets"
}

resource "aws_secretsmanager_secret_version" "db_secrets" {
  secret_id     = aws_secretsmanager_secret.db_secrets.id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.db_password.result
    host     = aws_db_instance.postgres.address
    port     = 5432
    dbname   = "postgres_db"
  })
}
