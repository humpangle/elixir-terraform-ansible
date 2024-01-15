resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

locals {
  key_name                 = "web-key"
  ssh_private_key_filename = abspath("${path.module}/ssh-key.pem")
  ansible_directory_root   = abspath("${path.module}/../ansible")
}

resource "aws_key_pair" "key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = local.ssh_private_key_filename
  file_permission = 0400
}

resource "aws_security_group" "web_public_sg" {
  name        = "web_public_sg"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.resource_tags, { name = "web_public_sg" })
}

resource "aws_instance" "web" {
  ami           = local.ami_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_public_sg.id]

  key_name = aws_key_pair.key_pair.key_name

  user_data_base64 = data.cloudinit_config.user_data_web.rendered

  tags = merge(
    var.resource_tags,
    { Name = "web" }
  )

  # Publish host dns to environment file
  provisioner "local-exec" {
    command = join(" ", [
      "sed -i",
      "s/PHX_HOST=.*/PHX_HOST=${aws_instance.web.public_dns}/g",
      "${var.ENV_FILENAME_TEMPORARY}",
    ])
  }
}

resource "local_file" "ansible_host_yaml" {
  depends_on = [aws_instance.web]

  filename        = "${local.ansible_directory_root}/hosts.temp.yaml"
  content         = local.ansible_host_yaml_content
  file_permission = 0400
}

resource "local_file" "ansible_deploy_yaml" {
  depends_on = [aws_instance.web]

  filename        = "${local.ansible_directory_root}/deploy.temp.yaml"
  content         = local.ansible_deploy_yaml_content
  file_permission = 0400
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_public_dns" {
  value = aws_instance.web.public_dns
}
