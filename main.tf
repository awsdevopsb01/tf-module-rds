resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "rds"
    from_port        = var.port_no
    to_port          = var.port_no
    protocol         = "tcp"
    cidr_blocks      = var.allow_db_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    #  cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name}-${var.env}-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-${var.env}-dsng"
  subnet_ids = var.subnets

  tags = merge(var.tags, {Name="${var.env}-sbg" })
}

data "aws_db_parameter_group" "main" {
  name = "${var.name}-${var.env}-dbpg"
  family = "aurora-mysql5.7"
}

resource "aws_rds_cluster" "rds" {
  cluster_identifier      = "${var.name}-${var.env}-rds"
  engine                  = "aurora-mysql"
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.db_user.value
  master_password         = data.aws_ssm_parameter.db_pass.value
  database_name           = "sample"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name = aws_db_subnet_group.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  storage_encrypted = true
  kms_key_id = var.kms_arn
  port = var.port_no
  tags = merge(var.tags, {Name="${var.name}-${var.env}" })
}

resource "aws_rds_cluster_instance" "rds_cluster_instance" {
  count              = var.instance_count
  identifier         = "Aurora-${var.env}-rds-instance"
  cluster_identifier = aws_rds_cluster.rds.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.rds.engine
  engine_version     = aws_rds_cluster.rds.engine_version
}