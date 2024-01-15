locals {
  ansible_host_yaml_content = templatefile(
    "./ansible-templates/hosts.tpl.yaml",
    {
      HOST_NAME                = var.HOST_NAME,
      INSTANCE_PUBLIC_IP       = aws_instance.web.public_ip,
      SSH_PRIVATE_KEY_FILENAME = local.ssh_private_key_filename
    }
  )
}

locals {
  ansible_deploy_yaml_content = templatefile(
    "./ansible-templates/deploy.tpl.yaml",
    {
      APP_DEPLOY_ROOT                          = var.APP_DEPLOY_ROOT,
      CONTAINER_IMAGE_NAME                     = var.CONTAINER_IMAGE_NAME,
      CONTAINER_NAME                           = var.CONTAINER_NAME,
      DOCKER_PUBLISHED_SERVER_LISTEN_HTTP_PORT = var.DOCKER_PUBLISHED_SERVER_LISTEN_HTTP_PORT,
      DOCKER_PUBLISHED_SERVER_LISTEN_PORT      = var.DOCKER_PUBLISHED_SERVER_LISTEN_PORT,
      ENV_FILENAME                             = var.ENV_FILENAME,
      ENV_FILENAME_TEMPORARY                   = var.ENV_FILENAME_TEMPORARY,
      HOST_NAME                                = var.HOST_NAME,
      HTTP_PORT                                = var.HTTP_PORT,
      PORT                                     = var.PORT,
    }
  )
}
