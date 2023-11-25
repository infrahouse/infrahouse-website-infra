data "aws_availability_zones" "uw1" {
  provider = aws.aws-uw1
  state    = "available"
}

data "aws_ami" "ubuntu_22" {
  provider    = aws.aws-uw1
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "aleks" {
  provider = aws.aws-uw1
  key_name = "aleks"
}

data "aws_route53_zone" "infrahouse_com" {
  name = "infrahouse.com"
}