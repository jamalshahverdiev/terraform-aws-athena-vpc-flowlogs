output "bucket_arn" {
  value = "${aws_s3_bucket.bucket_resource.arn}"
}

output "eks_cluster_output" {
  value = data.aws_eks_cluster.outputs.vpc_config[0].vpc_id
}