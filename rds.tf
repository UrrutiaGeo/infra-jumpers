resource "aws_db_parameter_group" "postgresql_10" {
  name = "postgresql"
  family = "postgres10"
  description = "Default parameter group for postgres10"
}

resource "aws_db_subnet_group" "default" {
  subnet_ids = [
    "${aws_subnet.subnets.*.id}"]
}

resource "aws_db_instance" "instance" {
  allocated_storage = 20
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  deletion_protection = true
  engine = "postgres"
  engine_version = "10"
  identifier = "${var.rds_instance_identifier}"
  instance_class = "db.t2.small"
  name = "clickeat"
  parameter_group_name = "${aws_db_parameter_group.postgresql_10.id}"
  password = "${var.db_password}"
  publicly_accessible = true
  skip_final_snapshot = true
  storage_type = "gp2"
  username = "${var.db_username}"
  vpc_security_group_ids = [
    "${aws_security_group.app.id}"
  ]
}