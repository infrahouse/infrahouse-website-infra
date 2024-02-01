module "website-vpc" {
  providers = {
    aws = aws.aws-uw1
  }
  source                = "infrahouse/service-network/aws"
  version               = "~> 2.0"
  management_cidr_block = var.management_cidr_block
  service_name          = "website"
  vpc_cidr_block        = "10.0.4.0/22"
  environment           = var.environment
  subnets = [
    {
      cidr                    = "10.0.4.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[0]
      map_public_ip_on_launch = true
      create_nat              = true
      forward_to              = ""
    },
    {
      cidr                    = "10.0.5.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[1]
      map_public_ip_on_launch = true
      create_nat              = true
      forward_to              = ""
    },
    {
      cidr                    = "10.0.6.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[0]
      map_public_ip_on_launch = false
      create_nat              = false
      forward_to              = "10.0.4.0/24"
    },
    {
      cidr                    = "10.0.7.0/24"
      availability-zone       = data.aws_availability_zones.uw1.names[1]
      map_public_ip_on_launch = false
      create_nat              = false
      forward_to              = "10.0.5.0/24"
    },
  ]
}
