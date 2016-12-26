data "aws_ami" "centos7" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # CentOS
}

resource "aws_instance" "centos7" {
  ami           = "${data.aws_ami.centos7.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.user_key.key_name}"

  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${aws_subnet.eu-west-1a-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name    = "CentOS Server"
    sshUser = "centos"
  }
}
