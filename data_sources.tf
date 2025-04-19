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
  provider = aws.aws-uw1
  name     = "infrahouse.com"
}

data "aws_vpc" "management" {
  filter {
    name = "tag:management"
    values = [
      true
    ]
  }
}

data "aws_subnets" "management_public" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.management.id
    ]
  }
  filter {
    name = "map-public-ip-on-launch"
    values = [
      true
    ]
  }
}

data "aws_subnets" "management_private" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.management.id
    ]
  }
  filter {
    name = "map-public-ip-on-launch"
    values = [
      false
    ]
  }
}

data "aws_internet_gateway" "management" {
  filter {
    name = "attachment.vpc-id"
    values = [
      data.aws_vpc.management.id
    ]
  }
}

data "aws_ami" "ubuntu_pro" {
  most_recent = true

  filter {
    name   = "name"
    values = [local.ami_name_pattern_pro]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "state"
    values = [
      "available"
    ]
  }

  owners = ["099720109477"] # Canonical
}
