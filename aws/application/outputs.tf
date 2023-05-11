output "webserver_ip" {
  value = aws_instance.web.private_ip
}

output "testserver_ip" {
  value = aws_instance.test.private_ip
}
