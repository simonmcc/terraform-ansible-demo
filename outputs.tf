output "public_ip" {
  value = "${aws_instance.centos7.public_ip}"
}
