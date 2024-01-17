resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

locals {
  key_name                 = "web-key-${var.PROJECT_NAME}"
  ssh_private_key_filename = "${var.DEV_OPS_ROOT_ANSIBLE}/ssh-key-${var.PROJECT_NAME}.gen.pem"
}

resource "aws_key_pair" "key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = local.ssh_private_key_filename
  file_permission = 0600
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
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

  tags = merge(
    var.resource_tags,
    { Name = "web_public_sg" }
  )
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.web_public_sg.id
  ]

  key_name = aws_key_pair.key_pair.key_name

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
  depends_on = [
    aws_instance.web
  ]

  filename        = local.ansible_host_file
  content         = local.ansible_host_yaml_content
  file_permission = 0600
}

resource "local_file" "ansible_deploy_yaml" {
  depends_on = [aws_instance.web]

  filename        = local.ansible_deploy_file
  content         = local.ansible_deploy_yaml_content
  file_permission = 0600
}

resource "null_resource" "run_ansible" {
  depends_on = [
    local_file.private_key,
    local_file.ansible_host_yaml,
    local_file.ansible_deploy_yaml
  ]

  # Wait for instance to get into "running" state
  # https://stackoverflow.com/a/76329674
  provisioner "local-exec" {
    command = join(
      " ",
      [
        "aws",
        "ec2",
        "wait",
        "instance-status-ok",
        "--instance-ids",
        aws_instance.web.id,
      ]
    )
  }

  provisioner "local-exec" {
    command = join(
      " ",
      [
        "ansible-playbook",
        "--inventory ",
        local.ansible_host_file,
        local.ansible_deploy_file
      ]
    )

    working_dir = var.DEV_OPS_ROOT_ANSIBLE
  }
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_public_dns" {
  value = aws_instance.web.public_dns
}
