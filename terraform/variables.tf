variable "region" {
    default = "us-east-1"
}

variable "project" {
    default = "dashlab"
}

variable "allowed_cidr" {
  type = string
}

variable "aws_account_id" {
  type      = string
  sensitive = true
}