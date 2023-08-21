module "cdn" {
  source = "./modules/cdn"
  providers = {
    aws     = aws.aws-uw1
    aws.ue1 = aws.aws-ue1
  }
}
