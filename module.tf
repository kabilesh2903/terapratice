resource "aws_instance" "instance" {
  instance_type = var.typetera
  key_name = var.keytera
  ami = var.amitera
  tags = {
    Name=var.nametera
  }
}