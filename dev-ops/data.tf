data "cloudinit_config" "user_data_web" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg" # name that will be used on the server.
    content_type = "text/cloud-config"
    content = templatefile("cloud-init-web.tpl.yaml", {
      docker_gpg_key_id = var.docker_gpg_key_id,
      container_registry_user_name = var.container_registry_user_name,
      container_registry_password = var.container_registry_password,
      container_image_name = var.container_image_name,
    })
  }
}
