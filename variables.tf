variable "aws_access_key" {
  description = "Access Key"
}

variable "aws_secret_key" {
  description = "Secret Key"
}

variable "key_name" {
  default = "urrutiageo"

  description = "Desired name of AWS key pair"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"

  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region to launch servers."
}

variable "db_username" {
  default     = "clickeat"
  description = "DB username for connection."
}

variable "db_password" {
  description = "DB password for connection."
}

variable "rds_instance_identifier" {
  default = "rdsclickeat"
}