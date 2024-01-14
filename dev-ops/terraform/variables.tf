variable "AWS_REGION" {
  type      = string
  sensitive = true
}


variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "DOCKER_GPG_KEY_ID" {
  type = string
}

variable "CONTAINER_REGISTRY_USER_NAME" {
  type      = string
  sensitive = true
}

variable "CONTAINER_REGISTRY_PASSWORD" {
  type      = string
  sensitive = true
}

variable "CONTAINER_IMAGE_NAME" {
  type      = string
  sensitive = true
}

variable "CONTAINER_NAME" {
  type = string
}

variable "ENV_FILENAME" {
  type = string
}

variable "ENV_FILENAME_TEMPORARY" {
  type = string
}

variable "APP_DEPLOY_ROOT" {
  type = string
}

variable "resource_tags" {
  type = map(string)
  default = {
    "project_name" = "elixir-terraform"
    "environment"  = "staging"
  }
}
