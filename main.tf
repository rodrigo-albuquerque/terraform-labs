resource "aws_vpc" "dc_tmp_vpc" {
  cidr_block = "172.16.199.0/24"

  tags = {
    Name = "albuquerque-VPC"
  }
}

resource "aws_subnet" "dc_tmp_subnet" {
  vpc_id = "${aws_vpc.dc_tmp_vpc.id}"
  cidr_block = "172.16.199.0/25"
  availability_zone = "us-east-1"

  tags = {
    Name = "albuquerque-dc_tmp_subnet"
  }
}

resource "aws_security_group" "dc_tmp-allow_tls_http_and_ssh" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.dc_tmp_vpc.id}"

  ingress {
    # TLS
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # SSH
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]# add your IP address here
  }

  egress {
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
  }

  tags = {
    Name = "dc_tmp_allow_all"
  }
}

resource "aws_instance" "albuquerque-debian-nginx-1" {
  ami                         = "${data.aws_ami.debian.id}"
  instance_type               = "t2.micro"
  key_name                    = "dckeypair"
  subnet_id                   = "{aws_subnet.dc_tmp_subnet.id}"
  vpc_security_group_ids      = "${aws_security_group.dc_tmp-allow_tls_http_and_ssh.id}"
  associate_public_ip_address = 1
  tags {
    Name = "Server1"
  }
}
