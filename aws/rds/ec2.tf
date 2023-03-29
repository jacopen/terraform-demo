resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name

  availability_zones = var.availability_zones

  engine_mode = "provisioned" # Serverless v2
  engine      = "aurora-postgresql"

  engine_version = "14.6"
  #database_name  = "testdb"

  master_username = "postgres"
  #master_password = var.master_password

  apply_immediately = var.apply_immediately

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  db_subnet_group_name = aws_db_subnet_group.this.name

  # Major Version Up は自動的に行わない
  allow_major_version_upgrade = false

  preferred_backup_window      = var.preferred_backup_window_in_utc
  preferred_maintenance_window = var.preffered_maintenance_window_in_utc
  backup_retention_period      = var.backup_retention_period_in_days
  final_snapshot_identifier    = join("", [var.name, "-", formatdate("YYYY-MM-DD-HH-mm-ss", timestamp())]) # undersocre は利用不可
  copy_tags_to_snapshot        = true

  # DB を削除可能とするか
  deletion_protection = var.deletion_protection

  # まずはログに出せるものは全て出力。問題があれば減らしていく。
  # 実質的に設定できる値は "postgresql" のみ
  enabled_cloudwatch_logs_exports = ["postgresql"]

  enable_http_endpoint = true

  iam_database_authentication_enabled = false

  vpc_security_group_ids = [aws_security_group.allow_db_client.id]

  # serverlessv2_scaling_configuration {
  #   min_capacity = var.minimum_capacity
  #   max_capacity = var.maximum_capacity
  # }

  tags = {
    Name = var.name
  }

  lifecycle {
    ignore_changes = [
      master_password,
      # 2 つの AZ しか設定しない場合であっても、AWS が 3 つを指定したことにするため、
      # 必ず差分が発生してしまう
      # see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#availability_zones
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "example" {
  count = var.replica_number + 1 # Master インスタンスで +1

  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  identifier           = "${var.name}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.this.id
  db_subnet_group_name = aws_rds_cluster.this.db_subnet_group_name

  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version

  apply_immediately = var.apply_immediately

  publicly_accessible = var.publicly_accessible

  # # メモリはみたいので、拡張モニタリングを有効化
  # monitoring_role_arn = aws_iam_role.monitoring.arn
  # monitoring_interval = 60 # CloudWatch の課金額を小さくするため最大間隔を指定

  instance_class = "db.serverless" # Aurora Serverless v2

  tags = {
    Name = "${var.name}-instance-${count.index}"
  }
}

resource "aws_db_subnet_group" "this" {
  subnet_ids = [data.aws_subnet.private_0.id, data.aws_subnet.private_1.id]

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_security_group" "allow_db_client" {
  name        = "allow db client"
  description = "Allow From Postgresql DB Client"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "${var.name} DB Client Access Rule"
  }
}

resource "aws_security_group_rule" "allow_db_client" {
  security_group_id = aws_security_group.allow_db_client.id
  type              = "ingress"

  description = "Allow From Postgresql DB Client"
  protocol    = "tcp"
  from_port   = 5432
  to_port     = 5432
  cidr_blocks = var.allow_db_access_cidr_blocks
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "aurora-parameter-group"
  family      = "aurora-postgresql13"
  description = "Cluster Parameter Group"

  parameter {
    name  = "deadlock_timeout"
    value = "10000"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name = "Aurora Parameter Group"
  }
}

# resource "aws_iam_role" "monitoring" {
#   name        = "EnhancedMonitoringRole"
#   description = "Role to enable enhanced monitoring"

#   assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
#   managed_policy_arns = [data.aws_iam_policy.enhanced_monitoring.arn]

#   tags = {
#     Name = "EnhancedMonitoringRole"
#   }
# }

# data "aws_iam_policy" "enhanced_monitoring" {
#   name = "AmazonRDSEnhancedMonitoringRole"
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["monitoring.rds.amazonaws.com"]
#     }
#   }
# }