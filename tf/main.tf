terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg_1" {
  name = "default"

  ingress {
    description = "App Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "kimang_key" {
  key_name   = "kimang-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhC/kNEer6SHxRh1BWChkxx0Dr4crG1kkqCqPiwFThtHbkuq7pHksB4/+m+oOfBhEndkYGLv2ezLQYClIqm+1NnR2NWv2OrsjwMzU1xmmczS0obzFRxA2uYcninAM13qTqT89wYz7A6rxi4ZeCHgbjya6iz+FIvZcNMZY8CAQuq7e8X2QM4DlllXJ4rbtWhZok7gVrv43lLhOfHQbrjV2fyTla0Eq8PCjjuGG78+8XvSlASaBxkUTR9bHjVXVi0oGgbIeN9Cj8tzzL5kkK6ubCvhiwkd2p2heFgsOPeIQhFrKEO1aj4B0eY0Nwaby+91dlYv6Y5DqPBUr7Z5KdwyOV kimang@KIMs-MacBook-Pro.local"
}

resource "aws_instance" "server_1" {
  ami  = "ami-ff0fea8310f3"
  instance_type = "t3.micro"
  count = 2
  key_name = aws_key_pair.kimang_key.key_name
  security_groups = [aws_security_group.sg_1.name]
  # user_data = <<-EOF
  #             #!/bin/bash
  #             apt update
  #             apt install git -y
  #             apt install curl -y
  #             apt install ping -y

  #             # Install NVM
  #             curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  #             . ~/.nvm/nvm.sh

  #             # Install Node.js 18
  #             nvm install 18

  #             # Install PM2
  #             npm install pm2 -g

  #             # Clone Node.js repository
  #             git clone https://github.com/KimangKhenng/devops-ex /root/devops-ex

  #             # Navigate to the repository and start the app with PM2
  #             cd /root/devops-ex
  #             npm install
  #             pm2 start app.js --name node-app -- -p 8000
  #           EOF
  user_data_replace_on_change = true
}