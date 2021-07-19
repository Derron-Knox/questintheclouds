#update security groups, private keys, and

#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}



#deploy quest application EC2s
resource "aws_instance" "quest-application" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.quest-instance-type
  key_name                    = "terraform"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.quest-application-servers.id]
  user_data                   = <<EOF
  #!/bin/bash
  sudo su -
  yum update -y
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  . ~/.nvm/nvm.sh
  nvm install node
  wget https://github.com/rearc/quest/archive/master.zip
  unzip master.zip
  mv quest-master/* ./
  rm -rf master.zip quest-master
  npm install && npm start
  EOF

  tags = {
    Team = "Rearc"
  }
}

