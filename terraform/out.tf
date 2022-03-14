output "ServerPublicIP" {
  value = aws_instance.ec2.*.public_ip
}
