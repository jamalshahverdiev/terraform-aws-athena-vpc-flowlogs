resource "aws_glue_catalog_database" "flowlogsdb" {
  name = var.flowlog_gb_glue_name
}

resource "aws_glue_crawler" "flowlog_crawler" {
  database_name = aws_glue_catalog_database.flowlogsdb.name
  name          = "flowlog_crawler"
  role          = aws_iam_role.s3_glue_role.arn

  s3_target {
    path = "s3://${var.bucket_name}/${var.athena_data_prefix}/"
  }
}

resource "aws_athena_workgroup" "query-workgroup" {
  name          = "query_workgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.bucket_name}/query-results/"
    }
  }
}