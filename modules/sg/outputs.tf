output "security_group" {
  value = aws_security_group.pawsome.id
}

output "bastion_host_sg" {
  value = aws_security_group.bastion_host_sg.id
}