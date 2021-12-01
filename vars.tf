variable "bucket_name" {
    type = string
    default = "vpc-flow-logs-bucket-name"
}

variable "eks_cluster_name" {
    type = string
    default = "eks-cluster-name-to-get-vpc-id"
}

variable "athena_data_prefix" {
    type = string
    default = "jamal.shahverdiev"
}

variable "flowlog_gb_glue_name" {
    type = string
    default = "flowloggluedb"
}