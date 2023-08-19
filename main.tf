module "website" {
  providers = {
    aws = aws.aws-uw1
  }
  source                = "infrahouse/website-pod/aws"
  version               = "~> 0.1"
  environment           = var.environment
  ami                   = data.aws_ami.ubuntu_22.image_id
  backend_subnets       = module.website-vpc.subnet_private_ids
  dns_zone              = "infrahouse.com"
  internet_gateway_id   = module.website-vpc.internet_gateway_id
  key_pair_name         = data.aws_key_pair.aleks.key_name
  subnets               = module.website-vpc.subnet_public_ids
  userdata              = module.webserver_userdata.userdata
  webserver_permissions = data.aws_iam_policy_document.webserver_permissions.json
}

module "webserver_userdata" {
  providers = {
    aws = aws.aws-uw1
  }
  source      = "infrahouse/cloud-init/aws"
  version     = "~> 1.1, >= 1.1.1"
  environment = var.environment
  role        = "webserver"
}

data "aws_iam_policy_document" "webserver_permissions" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}
