locals {
  ubuntu_codename      = "noble"
  ami_name_pattern_pro = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-${local.ubuntu_codename}-*"
  cdn_logs_bucket_name = "infrahouse-cdn-access-logs"
}
