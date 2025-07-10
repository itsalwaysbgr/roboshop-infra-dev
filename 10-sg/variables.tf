variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "frontend_sg_name" {
  default = "frontend"
}

variable "frontend_sg_description" {
  default = "created sg for frontend"
}

variable "bastion_sg_name" {
  default = "bastion"
}

variable "bastion_sg_description" {
  default = "created sg for bastion"
}

variable "mongodb_ports_vpn" {
  default = [22, 27017]
}

variable "mysql_ports_vpn" {
  default = [22, 3306]
}

variable "redis_ports_vpn" {
  default = [22, 6379]
}

variable "rabbitmq_ports_vpn" {
  default = [22, 5672]
}