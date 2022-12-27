output "publicip" {
  #value = aws_instance.ex[*].id
  value = [for i in aws_instance.ex : i.public_ip]
}

output "publicip_map" {
  value = { for az,i in aws_instance.ex : az => i.id }

}
