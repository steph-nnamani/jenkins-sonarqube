# Declaring the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "Jenkins" {
  ami                    = "ami-0557a15b87f6559cf" # free tier AMI image
  instance_type          = "t2.medium"
  user_data              = file("jenkins_script.sh")
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = "newkey" # Existing ssh key 

  tags = {
    Name = "Jenkins_Instance"
  }
}


data "aws_route53_zone" "selected" {
  name         = "zaralinktech.com"
  private_zone = false
}

resource "aws_route53_record" "jenkins_domain" {
  name    = "jenkins"
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id
  records = [aws_instance.Jenkins.public_ip]
  ttl     = 300
  depends_on = [
    aws_instance.Jenkins
  ]
}