resource "aws_secretsmanager_secret" "db_secrets" {
  name                    = "db_secrets"
  recovery_window_in_days = 0 # since this is a project and i need to destroy/apply infra daily and by def secrets stay for 7 days to be recovered
}

resource "aws_secretsmanager_secret_version" "db_secrets" {
  secret_id = aws_secretsmanager_secret.db_secrets.id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.db_password.result
    host     = aws_db_instance.postgres.address
    port     = 5432
    dbname   = "postgres_db"
  })
}
