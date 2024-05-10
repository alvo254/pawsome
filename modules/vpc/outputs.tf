output "private_subent1" {
  value = aws_subnet.private_subent1.id
}

output "public_subnet1" {
  value = aws_subnet.public_subnet1.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
