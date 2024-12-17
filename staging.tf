module "website-staging" {
  providers = {
    aws     = aws.aws-uw1
    aws.dns = aws.aws-uw1
  }
  source                       = "infrahouse/website-pod/aws"
  version                      = "~> 4.6"
  environment                  = "development"
  ami                          = "ami-0ea80799a59ad106b"
  backend_subnets              = data.aws_subnets.management_private.ids
  zone_id                      = data.aws_route53_zone.infrahouse_com.zone_id
  dns_a_records                = ["staging"]
  internet_gateway_id          = data.aws_internet_gateway.management.id
  key_pair_name                = data.aws_key_pair.aleks.key_name
  subnets                      = data.aws_subnets.management_public.ids
  userdata                     = module.webserver_userdata-staging.userdata
  instance_profile_permissions = data.aws_iam_policy_document.webserver_permissions.json
  stickiness_enabled           = true
  alb_access_log_enabled       = true
  on_demand_base_capacity      = 0
}

module "webserver_userdata-staging" {
  providers = {
    aws = aws.aws-uw1
  }
  source                   = "infrahouse/cloud-init/aws"
  version                  = "~> 1.6"
  environment              = "development"
  role                     = "webserver"
  puppet_hiera_config_path = "/opt/infrahouse-puppet-data/environments/development/hiera.yaml"
  packages = [
    "infrahouse-puppet-data"
  ]
}
