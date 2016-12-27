resource "aws_key_pair" "user_key" {
  key_name   = "terraform-ansible-demo"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
