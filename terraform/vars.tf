variable "mysql_root_password" {
  description = "The password for the root MySQL user"
  default     = "password"
}

variable "mysql_db_name" {
  description = "The name of the MySQL database to be created"
  default     = "wordpress_db"
}
