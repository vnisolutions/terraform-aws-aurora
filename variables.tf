variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
}

variable "subnet_ids" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
}

variable "env" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "project_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "db_name" {
  description = "Database administrator username"
  type        = string
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
}

variable "db_instance_class" {
  description = "Database administrator password"
  type        = string
}

variable "engine" {
  description = "Database administrator password"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Database administrator password"
  type        = string
  default     = "8.0.mysql_aurora.3.02.0"
}

variable "db_instance_count" {
  description = "Database administrator password"
  type        = number
}

variable "sg_ingress" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
  default = null
}

variable "cidr_ingress" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
  default = null
}

variable "publicly_accessible" {
  description = "Database administrator password"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Database administrator password"
  type        = bool
  default     = false
}

variable "mysql_family" {
  description = "Database administrator password"
  type        = string
  default     = "aurora-mysql8.0"
}

variable "postgresql_family" {
  description = "Database administrator password"
  type        = string
  default     = "aurora-postgresql14"
}