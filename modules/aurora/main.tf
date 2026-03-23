# -----------------------------------------------------------------------------
# Aurora
# -----------------------------------------------------------------------------

# Create Aurora Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.prefix}-aurora-subnet-group"
  subnet_ids = [var.data_a_id, var.data_b_id]

  tags = {
    Name        = "${var.prefix}-aurora-subnet-group"
    Environment = var.environment
  }
}

# Create Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier          = "${var.prefix}-aurora"
  engine                      = "aurora-mysql"
  engine_mode                 = "provisioned"
  engine_version              = var.engine_version
  database_name               = var.database_name
  master_username             = "admin"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.aurora.name
  vpc_security_group_ids      = [var.aurora_sg_id]
  skip_final_snapshot         = true
  storage_encrypted           = true

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  tags = {
    Name        = "${var.prefix}-aurora"
    Environment = var.environment
  }
}

# Create Aurora Writer Instance
resource "aws_rds_cluster_instance" "aurora_writer" {
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = var.engine_version

  tags = {
    Name        = "${var.prefix}-aurora-writer"
    Environment = var.environment
  }
}