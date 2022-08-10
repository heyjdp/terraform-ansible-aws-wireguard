resource "aws_key_pair" "devops_key_pair" {
  key_name   = "devops-key-pair"
  public_key = file("~/code/terraform-ansible-example/devops_aws_key.pub")
}

resource "aws_vpc" "nginx_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "nginx_public_subnet" {
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = "10.20.1.0/24"
  #map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"

  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_internet_gateway" "nginx_internet_gateway" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "nginx_public_rt" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "nginx_public_route" {
  route_table_id         = aws_route_table.nginx_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nginx_internet_gateway.id
}

resource "aws_route_table_association" "nginx_public_assoc" {
  subnet_id      = aws_subnet.nginx_public_subnet.id
  route_table_id = aws_route_table.nginx_public_rt.id
}

resource "aws_security_group" "nginx_sg" {
  name        = "dev-sg"
  description = "Dev security group"
  vpc_id      = aws_vpc.nginx_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_ec2" {
  instance_type               = "t3.micro"
  ami                         = data.aws_ami.server_ami.id
  key_name                    = aws_key_pair.devops_key_pair.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.nginx_public_subnet.id

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-nginx"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = aws_instance.nginx_ec2.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.nginx_ec2.public_ip}, --private-key ${var.private_key_path} aws-server.yaml"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx_ec2.public_ip
}