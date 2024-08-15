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
  region                      = "us-east-1"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://s3.localhost.localstack.cloud:4566"
  }

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


resource "aws_key_pair" "songhay-key" {
  key_name   = "p-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxLfy1ttfrTKXRJU2L8Cdd7qIDuRaIdA1/pQ/pOjuWv43ueUdwhyi7uBmG4Pq7ZMo7z7Mr4Hxnl4bzpvwJyr2rRvqsbsqXJLYeDSSdvl1Ih7qgUK7gOI3Hn3PW3fBamfUAaDbIM3qiuThTZyY6BIWJmmg1QESnrwQNnnaScdrCgwtJ5J9PCGnUyW8QLHOPpkurwh2GczkfdlaZfMh/JuLu/pAd4gPNpMqT7dJZi/NM5+9LKd72XLKIw2nBPUPH76QUPc2x6YGQExOLCKpJ+Dsl9efdDXlwngnn5gTQdoVuQHxy2fXshF1kT3UOgbL8pJLiUOFGG1IV1v65m7Xvng9N dev@DESKTOP-V4PJU36"
}

resource "aws_instance" "server_1" {
  ami                         = "ami-ff0fea8310f3"
  instance_type               = "t3.micro"
  count                       = 2
  key_name                    = aws_key_pair.songhay-key.key_name
  security_groups             = [aws_security_group.sg_1.name]
  user_data                   = <<-EOF
              #!/bin/bash
              apt update -y
              apt install python3 -y
            EOF
  user_data_replace_on_change = true
  # We comment this because we are want to using ansible provisioner (to use configuration management tools)
  # if we use this, we must use if we need to chnage the user_data we need to down and up server
  # user_data                   = <<-EOF
  #             #!/bin/bash
  #             apt update -y
  #             apt install curl -y
  #             apt install git -y
  #             # Install NVM
  #             curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  #             . ~/.nvm/nvm.sh
  #             # Install Node.js 18
  #             nvm install 18
  #             # Install PM2
  #             npm install pm2 -g
  #             # Clone Node.js repository
  #             git clone https://github.com/songhay168/devops-ex /root/devops-ex
  #             # Navigate to the repository and start the app with PM2
  #             cd /root/devops-ex
  #             npm install
  #             pm2 start app.js --name node-app -- -p 8000
  #           EOF
  # user_data_replace_on_change = true
}
