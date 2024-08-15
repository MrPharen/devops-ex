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


resource "aws_key_pair" "pharen-key" {
  key_name   = "pharen-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2SbOZ+ikceEy9nFYQ/h1MAtt1BGkk4tLZHSb/GvtYAlWFtoulKFkCbycIyL2LBuyMWUnD+qFDM0kRHvs2Nsn3dy/6zf7b3/q6Y9RtGkeAsdwxgbd59EGkeXqbShTSkyL3aPDlmEdspRWDPG2cJdI7KMyzTnUWKqEY1k2lMyBM7vsQXkmluK67FrfT3Rsfe4RoQhEmS9/o76COR9I6AMJ5nh5bQqI2PG4Oyuh9GOGp1Zj9Z2r/XoURGssEDgGxbFgK3JVVIh0lbAkMB+dlUAVlQIDHAgC/mnTpBztJTbLJ7XkneHhq8y0irO1ItRcjtqtysc97A8H+cgnb/bvqMNiH mac@PHARENs-MacBook-Pro.local"
}

resource "aws_instance" "server_1" {
  ami  = "ami-ff0fea8310f3"
  instance_type = "t3.micro"
  count = 2
  key_name = aws_key_pair.pharen-key.key_name
  security_groups = [aws_security_group.sg_1.name]
  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install git -y
              apt install curl -y

              # Install NVM
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
              . ~/.nvm/nvm.sh

              # Install Node.js 18
              nvm install 18

              # Install PM2
              npm install pm2 -g

              # Clone Node.js repository
              git clone https://github.com/MrPharen/devops-ex /root/devops-ex

              # Navigate to the repository and start the app with PM2
              cd /root/devops-ex
              npm install
              pm2 start app.js --name node-app -- -p 8000
            EOF
  user_data_replace_on_change = true
}