data "aws_security_group" "launchwizard-1" {
  id = "sg-0526b813be020858b"
}
resource "aws_instance" "demoinstance" {
  ami                     = "ami-0f34c5ae932e6f0e4"
  instance_type           = var.instance_type
  subnet_id = "subnet-03f258d3cd3624efe"
  security_groups = [data.aws_security_group.launchwizard-1.id]
  key_name = "myserver"
  user_data = file("${path.module}/script.sh")
  tags = {Name="Terraform"}
}
