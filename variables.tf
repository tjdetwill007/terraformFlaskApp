variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "This is the value of instance"

}

output "Public_DNS" {

  value = "Public DNS is : ${aws_instance.demoinstance.public_ip}}"

}