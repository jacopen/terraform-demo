output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_0_subnet_id" {
  value = aws_subnet.public_0.id
}

output "public_1_subnet_id" {
  value = aws_subnet.public_1.id
}

output "private_0_subnet_id" {
  value = aws_subnet.private_0.id
}

output "private_1_subnet_id" {
  value = aws_subnet.private_1.id
}
