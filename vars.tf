variable "name" {
  default = "rds"
}
variable "engine_version" {}
variable "port_no" {
  default = "3306"
}
variable "env" {}
variable "kms_arn" {}
variable "tags" {}
variable "allow_db_cidr" {}
variable "subnets" {}
variable "vpc_id" {}
variable "instance_count" {}
variable "instance_class" {}