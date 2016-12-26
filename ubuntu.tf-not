data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web-1" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.user_key.key_name}"

  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${aws_subnet.eu-west-1a-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name    = "Ubuntu Server"
    sshUser = "ubuntu"
  }
}

resource "aws_eip" "web-1" {
  instance = "${aws_instance.web-1.id}"
  vpc      = true
}
