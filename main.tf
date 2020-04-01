resource "aws_vpc" "albuquerque_vpc" {
  cidr_block = "172.16.199.0/24"

  tags = {
    Name = "albuquerque_vpc"
  }
}

resource "aws_subnet" "albuquerque_subnet" {
  vpc_id            = aws_vpc.albuquerque_vpc.id
  cidr_block        = "172.16.199.0/25"
  availability_zone = "us-east-1a"

  tags = {
    Name = "albuquerque_subnet"
  }
}

resource "aws_route_table_association" "albuquerque_subnet_association" {
  subnet_id      = aws_subnet.albuquerque_subnet.id
  route_table_id = aws_route_table.albuquerque_rt.id
}

resource "aws_security_group" "albuquerque_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.albuquerque_vpc.id

  ingress {
    # SSH,
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }

  ingress {
    # HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # HTTPS
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }

  ingress {
    # ICMPv4
    from_port   = 0
    to_port     = 0
    protocol    = "ICMPv4"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "albuquerque_sg"
  }
}

resource "aws_internet_gateway" "albuquerque_igw" {
  vpc_id = aws_vpc.albuquerque_vpc.id

  tags = {
    Name = "albuquerque_igw"
  }
}

resource "aws_route_table" "albuquerque_rt" {
  vpc_id = aws_vpc.albuquerque_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.albuquerque_igw.id
  }

  tags = {
    Name = "albuquerque_rt"
  }
}

resource "aws_instance" "albuquerque-debian-nginx-lb" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t2.micro"
  key_name                    = "dckeypair"
  subnet_id                   = aws_subnet.albuquerque_subnet.id
  vpc_security_group_ids      = [aws_security_group.albuquerque_sg.id]
  associate_public_ip_address = true
  private_ip                  = "172.16.199.120"
  depends_on                  = [aws_internet_gateway.albuquerque_igw]
  tags = {
    Name = "albuquerque-debian-nginx-lb"
  }
}

resource "aws_instance" "albuquerque-debian-nginx-srv1" {
  ami                    = data.aws_ami.debian.id
  instance_type          = "t2.micro"
  key_name               = "dckeypair"
  subnet_id              = aws_subnet.albuquerque_subnet.id
  vpc_security_group_ids = [aws_security_group.albuquerque_sg.id]
  private_ip             = "172.16.199.31"
  depends_on             = [aws_instance.albuquerque-debian-nginx-lb]
  tags = {
    Name = "albuquerque-debian-nginx-srv1"
  }
}

resource "aws_instance" "albuquerque-debian-nginx-srv2" {
  ami                    = data.aws_ami.debian.id
  instance_type          = "t2.micro"
  key_name               = "dckeypair"
  subnet_id              = aws_subnet.albuquerque_subnet.id
  vpc_security_group_ids = [aws_security_group.albuquerque_sg.id]
  private_ip             = "172.16.199.32"
  depends_on             = [aws_instance.albuquerque-debian-nginx-lb]
  tags = {
    Name = "albuquerque-debian-nginx-srv2"
  }

}
