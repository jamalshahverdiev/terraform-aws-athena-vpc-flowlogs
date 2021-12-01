module "vpc_flowlogs" {
  source = "barundel/flowlogs/aws"
  vpc_id = data.aws_eks_cluster.outputs.vpc_config[0].vpc_id
  log_destination = aws_s3_bucket.bucket_resource.arn
  log_destination_type = "s3"
  log_format = "$${version} $${account-id} $${instance-id} $${interface-id} $${pkt-srcaddr} $${srcaddr} $${srcport} $${pkt-dstaddr} $${dstaddr} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${az-id}"
}