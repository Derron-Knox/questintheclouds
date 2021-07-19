# output bastion IP to CLI
output "quest-Public-IP" {
  value = aws_instance.quest-application.public_ip
}
