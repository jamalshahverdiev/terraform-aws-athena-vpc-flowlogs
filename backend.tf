terraform {
  backend "s3" {
    bucket = "projectname-terraform-states"
    key    = "prod/projectname/vpcflowlogs.state"
    region = "us-east-1"
  }
}