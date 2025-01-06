data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name    = "test-postgresql"
  region  = "us-east-1"

  vpc_cidr = "vpc-0f56a538178e0c400"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/Devopstrainingforme/test-aws-resource.git"
  }
}
module "db" {
  source = "git::https://github.com/Devopstrainingforme/RDSModule.git"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                   = "postgres"
  engine_version           = "14"
  family                   = "postgres14" # DB parameter group
  major_engine_version     = "14"         # DB option group
  instance_class           = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 20

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = "TestPostgresql"
  username = "test_postgresql"
  port     = 5432

  # Setting manage_master_user_password_rotation to false after it
  # has previously been set to true disables automatic rotation
  # however using an initial value of false (default) does not disable
  # automatic rotation and rotation will be handled by RDS.
  # manage_master_user_password_rotation allows users to configure
  # a non-default schedule and is not meant to disable rotation
  # when initially creating / enabling the password management feature
  manage_master_user_password_rotation              = false
  master_user_password_rotate_immediately           = false

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  skip_final_snapshot     = false
  deletion_protection     = false

  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  create_monitoring_role                = false
}