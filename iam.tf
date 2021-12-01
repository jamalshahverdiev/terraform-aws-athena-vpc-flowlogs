resource "aws_iam_role" "s3_glue_role" {
  name               = "s3_glue_role"
  assume_role_policy = data.aws_iam_policy_document.glue-assume-role-policy.json
}

data "aws_iam_policy_document" "glue-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "extra-policy" {
  name        = "extra-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.extra-policy-document.json

}

data "aws_iam_policy_document" "extra-policy-document" {
  statement {
    actions = [
    "s3:GetBucketLocation", "s3:ListBucket", "s3:ListAllMyBuckets", "s3:GetBucketAcl", "s3:GetObject"]
    resources = [
      "${aws_s3_bucket.bucket_resource.arn}",
      "${aws_s3_bucket.bucket_resource.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "extra-policy-attachment" {
  role       = aws_iam_role.s3_glue_role.name
  policy_arn = aws_iam_policy.extra-policy.arn
}

resource "aws_iam_role_policy_attachment" "glue-service-role-attachment" {
  role       = aws_iam_role.s3_glue_role.name
  policy_arn = data.aws_iam_policy.AWSGlueServiceRole.arn
}

data "aws_iam_policy" "AWSGlueServiceRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}