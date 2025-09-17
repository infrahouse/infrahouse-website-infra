module "website" {
  providers = {
    aws     = aws.aws-uw1
    aws.dns = aws.aws-uw1
  }
  source                       = "infrahouse/website-pod/aws"
  version                      = "5.8.2"
  environment                  = var.environment
  ami                          = data.aws_ami.ubuntu_pro.id
  backend_subnets              = data.aws_subnets.management_private.ids
  zone_id                      = data.aws_route53_zone.infrahouse_com.zone_id
  dns_a_records                = ["", "www"]
  internet_gateway_id          = data.aws_internet_gateway.management.id
  key_pair_name                = data.aws_key_pair.aleks.key_name
  subnets                      = data.aws_subnets.management_public.ids
  userdata                     = module.webserver_userdata.userdata
  instance_profile_permissions = data.aws_iam_policy_document.webserver_permissions.json
  stickiness_enabled           = true
  alb_access_log_enabled       = true
  on_demand_base_capacity      = 1
}

module "webserver_userdata" {
  providers = {
    aws = aws.aws-uw1
  }
  source                   = "infrahouse/cloud-init/aws"
  version                  = "2.2.0"
  environment              = var.environment
  ubuntu_codename          = local.ubuntu_codename
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
