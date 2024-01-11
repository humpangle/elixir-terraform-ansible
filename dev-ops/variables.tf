variable "aws_region" {
  type      = string
  sensitive = true
}


variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "docker_gpg_key_id" {
  type = string
}

variable "resource_tags" {
  type = map(string)
  default = {
    "project_name" = "elixir-terraform"
    "environment"  = "staging"
  }
}
