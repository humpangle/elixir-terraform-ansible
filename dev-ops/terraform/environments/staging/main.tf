module "web_server" {
  source = "../../modules/web_server"

  APP_DEPLOY_ROOT                          = var.APP_DEPLOY_ROOT
  AWS_PROFILE                              = var.AWS_PROFILE
  AWS_REGION                               = var.AWS_REGION
  CONTAINER_IMAGE_NAME                     = var.CONTAINER_IMAGE_NAME
  CONTAINER_NAME                           = var.CONTAINER_NAME
  CONTAINER_REGISTRY_PASSWORD              = var.CONTAINER_REGISTRY_PASSWORD
  CONTAINER_REGISTRY_USER_NAME             = var.CONTAINER_REGISTRY_USER_NAME
  DEV_OPS_ROOT                             = var.DEV_OPS_ROOT
  DEV_OPS_ROOT_ANSIBLE                     = var.DEV_OPS_ROOT_ANSIBLE
  DEV_OPS_ROOT_TERRAFORM                   = var.DEV_OPS_ROOT_TERRAFORM
  DOCKER_PUBLISHED_SERVER_LISTEN_HTTP_PORT = var.DOCKER_PUBLISHED_SERVER_LISTEN_HTTP_PORT
  DOCKER_PUBLISHED_SERVER_LISTEN_PORT      = var.DOCKER_PUBLISHED_SERVER_LISTEN_PORT
  ENV_FILENAME                             = var.ENV_FILENAME
  ENV_FILENAME_TEMPORARY                   = var.ENV_FILENAME_TEMPORARY
  HOST_NAME                                = var.HOST_NAME
  HTTP_PORT                                = var.HTTP_PORT
  PORT                                     = var.PORT
  PROJECT_NAME                             = var.PROJECT_NAME
}

output "web_public_ip" {
  value = module.web_server.web_public_ip
}

output "web_public_dns" {
  value = module.web_server.web_public_dns
}
