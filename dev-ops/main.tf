resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

locals {
  key_name                 = "web-key"
  ssh_private_key_filename = "ssh-key.pem"
}

resource "aws_key_pair" "key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
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

  user_data_base64 = data.cloudinit_config.user_data_web.rendered

  tags = merge(
    var.resource_tags,
    { Name = "web" }
  )
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_public_dns" {
  value = aws_instance.web.public_dns
}

# sudo cat /var/lib/cloud/instances/i-0cb9fc801e4d1c31f/user-data.txt
