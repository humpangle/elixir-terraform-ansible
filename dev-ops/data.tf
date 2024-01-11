data "cloudinit_config" "user_data_web" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg" # name that will be used on the server.
    content_type = "text/cloud-config"
    content      = templatefile("cloud-init-web.tpl.yaml", {})
  }
}
