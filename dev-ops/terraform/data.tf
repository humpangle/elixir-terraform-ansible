data "cloudinit_config" "user_data_web" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg" # name that will be used on the server.
    content_type = "text/cloud-config"
    content = templatefile("cloud-init-web.tpl.yaml", {
      DOCKER_GPG_KEY_ID            = var.DOCKER_GPG_KEY_ID,
      CONTAINER_REGISTRY_USER_NAME = var.CONTAINER_REGISTRY_USER_NAME,
      CONTAINER_REGISTRY_PASSWORD  = var.CONTAINER_REGISTRY_PASSWORD,
      CONTAINER_IMAGE_NAME         = var.CONTAINER_IMAGE_NAME,
      APP_DEPLOY_ROOT              = var.APP_DEPLOY_ROOT,
    })
  }
}
