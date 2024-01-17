variable "AWS_REGION" {
  type      = string
  sensitive = true
}

variable "AWS_PROFILE" {
  type      = string
  sensitive = true
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

variable "PORT" {
  type = string
}

variable "DOCKER_PUBLISHED_SERVER_LISTEN_PORT" {
  type = string
}

variable "HOST_NAME" {
  type = string
}

variable "DOCKER_PUBLISHED_SERVER_LISTEN_HTTP_PORT" {
  type = string
}

variable "HTTP_PORT" {
  type = string
}

variable "PROJECT_NAME" {
  type = string
}

variable "DEV_OPS_ROOT" {
  type = string
}

variable "DEV_OPS_ROOT_TERRAFORM" {
  type = string
}

variable "DEV_OPS_ROOT_ANSIBLE" {
  type = string
}

variable "resource_tags" {
  type = map(string)
  default = {
    "project_name" = "elixir-terraform"
    "environment"  = "staging"
  }
}
