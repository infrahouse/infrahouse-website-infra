module "cdn" {
  source                     = "./modules/cdn"
  cdn_hostname               = "cdn"
  logging_bucket_domain_name = module.cdn_access_logs.bucket_regional_domain_name
}

module "cdn_staging" {
  source                     = "./modules/cdn"
  cdn_hostname               = "cdn-staging"
  logging_bucket_domain_name = module.cdn_access_logs.bucket_regional_domain_name
}
