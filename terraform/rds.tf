# SG

resource "aws_security_group" "postgres_SG" {
  name   = "postgres_SG"
  vpc_id = module.vpc.vpc_id

  tags = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_app" {
  security_group_id = aws_security_group.postgres_SG.id
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_traffic_app" {
  security_group_id            = aws_security_group.postgres_SG.id
  referenced_security_group_id = module.eks.node_security_group_id
  ip_protocol                  = "-1" # semantically equivalent to all ports
}

# DB
# Secrets Manager + ESO is the right call over IAM DB auth as IAM DB auth with Spring Boot adds significant complexity (token refresh every 15 mins).
resource "aws_db_instance" "postgres" {
  allocated_storage      = 5
  storage_encrypted      = true
  db_name                = "postgres_db"
  engine                 = "postgres"
  engine_version         = "18.6"
  username               = "postgres"
  password               = random_password.db_password.result
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.db-sg-grp.name
  vpc_security_group_ids = [aws_security_group.postgres_SG.id]
  skip_final_snapshot    = true
  multi_az               = false # as this is for personal use, we don't need multi-AZ for high availability
}

resource "aws_db_subnet_group" "db-sg-grp" {
  name       = "postgres-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# DB Secret
resource "random_password" "db_password" {
  length  = 16
  special = false # avoids issues with JDBC connection strings
}