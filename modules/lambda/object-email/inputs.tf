variable "app_name" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "destination_addresses" {
  type = "list"
  default = ["success@simulator.amazonses.com"]
}

variable "source_address" {
  type = "string"
  default = "no_reply@email_address.com"
}

variable "reply_addresses" {
  type = "list"
  default = ["no_reply@email_address.com"]
}

variable "lambda_source_dir" {
  type = "string"
  default = "./modules/lambda/object-email/src"
}

variable "lambda_source_file" {
  type = "string"
  default = "index.js"
}

variable "lambda_dist_dir" {
  type = "string"
  default = "./modules/lambda/object-email/dist"
}