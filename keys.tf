resource "aws_key_pair" "user_key" {
  key_name   = "user_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
