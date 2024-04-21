module "website" {
  providers = {
    aws     = aws.aws-uw1
    aws.dns = aws.aws-uw1
  }
  source                = "infrahouse/website-pod/aws"
  version               = "~> 2.6"
  environment           = var.environment
  ami                   = "ami-0ea80799a59ad106b"
  backend_subnets       = module.website-vpc.subnet_private_ids
  zone_id               = data.aws_route53_zone.infrahouse_com.zone_id
  internet_gateway_id   = module.website-vpc.internet_gateway_id
  key_pair_name         = data.aws_key_pair.aleks.key_name
  subnets               = module.website-vpc.subnet_public_ids
  userdata              = module.webserver_userdata.userdata
  webserver_permissions = data.aws_iam_policy_document.webserver_permissions.json
  stickiness_enabled    = true
  ssh_cidr_block        = var.management_cidr_block
}

module "webserver_userdata" {
  providers = {
    aws = aws.aws-uw1
  }
  source                   = "infrahouse/cloud-init/aws"
  version                  = "~> 1.6"
  environment              = var.environment
  role                     = "webserver"
  puppet_hiera_config_path = "/opt/infrahouse-puppet-data/environments/${var.environment}/hiera.yaml"
  packages = [
    "infrahouse-puppet-data"
  ]
}

data "aws_iam_policy_document" "webserver_permissions" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}
