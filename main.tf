resource "aws_db_subnet_group" "aurora" {
  name        = "${var.env}-${var.project_name}-aurora"
  subnet_ids  = var.subnet_ids
  description = "Aurora subnet group"

  tags = {
    Name        = "${var.env}-${var.project_name}-aurora"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_rds_cluster_parameter_group" "cluster_paramater_group_mysql" {
  count  = var.engine == "aurora-mysql" ? 1 : 0
  name   = "${var.env}-${var.project_name}-cluster-parameter-group-mysql"
  family = var.mysql_family
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "general_log"
    value = 1
  }
  parameter {
    name  = "log_queries_not_using_indexes"
    value = 0
  }
  parameter {
    name  = "long_query_time"
    value = 0.5
  }
  parameter {
    name  = "max_allowed_packet"
    value = 33554432
  }
  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
  parameter {
    name  = "slow_query_log"
    value = 1
  }
  parameter {
    name  = "sql_mode"
    value = "NO_ENGINE_SUBSTITUTION"
  }
  parameter {
    name  = "time_zone"
    value = var.time_zone
  }
  parameter {
    name  = "transaction_isolation"
    value = "REPEATABLE-READ"
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-cluster-parameter-group"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_rds_cluster_parameter_group" "cluster_paramater_group_postgresql" {
  count  = var.engine == "aurora-postgresql" ? 1 : 0
  name   = "${var.env}-${var.project_name}-cluster-parameter-group-postgresql"
  family = var.postgresql_family
  parameter {
    name  = "client_encoding"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "timezone"
    value = var.time_zone
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-cluster-parameter-group"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_db_parameter_group" "db_parameter_group_mysql" {
  count  = var.engine == "aurora-mysql" ? 1 : 0
  name   = "${var.env}-${var.project_name}-db-parameter-group"
  family = var.mysql_family
  parameter {
    name  = "general_log"
    value = 1
  }
  parameter {
    name  = "log_queries_not_using_indexes"
    value = 0
  }
  parameter {
    name  = "long_query_time"
    value = 0.5
  }
  parameter {
    name  = "max_allowed_packet"
    value = 33554432
  }
  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
  parameter {
    name  = "slow_query_log"
    value = 1
  }
  parameter {
    name  = "sql_mode"
    value = "NO_ENGINE_SUBSTITUTION"
  }
  parameter {
    name  = "transaction_isolation"
    value = "REPEATABLE-READ"
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-db-parameter-group"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_db_parameter_group" "db_parameter_group_postgresql" {
  count  = var.engine == "aurora-postgresql" ? 1 : 0
  name   = "${var.env}-${var.project_name}-db-parameter-group"
  family = var.postgresql_family
  parameter {
    name  = "client_encoding"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-db-parameter-group"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier              = "${var.env}-${var.project_name}-cluster"
  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  engine                          = var.engine
  engine_version                  = var.engine_version
  database_name                   = var.db_name
  db_cluster_parameter_group_name = var.engine == "aurora-postgresql" ? aws_rds_cluster_parameter_group.cluster_paramater_group_postgresql.*.id[0] : aws_rds_cluster_parameter_group.cluster_paramater_group_mysql.*.id[0]
  master_username                 = var.db_username
  master_password                 = var.db_password
  backup_retention_period         = 7
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  apply_immediately               = true
  vpc_security_group_ids          = [aws_security_group.sg-aurora.id]
  deletion_protection             = false
  storage_encrypted               = var.storage_encrypted
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                   = var.db_instance_count
  identifier              = "${var.env}-${var.project_name}-${count.index}"
  cluster_identifier      = aws_rds_cluster.cluster.id
  instance_class          = var.db_instance_class
  engine                  = aws_rds_cluster.cluster.engine
  engine_version          = aws_rds_cluster.cluster.engine_version
  db_parameter_group_name = var.engine == "aurora-postgresql" ? aws_db_parameter_group.db_parameter_group_postgresql.*.id[0] : aws_db_parameter_group.db_parameter_group_mysql.*.id[0]
  apply_immediately       = aws_rds_cluster.cluster.apply_immediately
  publicly_accessible     = var.publicly_accessible
}

resource "aws_security_group" "sg-aurora" {
  name        = "${var.env}-${var.project_name}-aurora-sg"
  description = "Allow Fargate to access aurora"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "allow access aurora"
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = var.cidr_ingress
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = var.sg_ingress
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null

    }
  ]

  tags = {
    Name        = "${var.env}-${var.project_name}-aurora-sg"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}
