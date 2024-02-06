data "aws_s3_bucket" "existing_bucket" {
  bucket = "<existing_bucket_name>"
}

output "static_website_enabled" {
  value = data.aws_s3_bucket.existing_bucket.website_endpoint != null ? true : false
}
resource "aws_s3_bucket_policy" "bucket_policy" { 
  count = data.aws_s3_bucket.existing_bucket.website_endpoint == null ? 1 : 0
  bucket  = data.aws_s3_bucket.existing_bucket.id

  policy = jsonencode({
    "Id"      : "SecureTransportPolicy",
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Sid"       : "AllowSSLRequestsOnly",
        "Action"    : "s3:*",
        "Effect"    : "Deny",
        "Resource"  : [
          "${data.aws_s3_bucket.existing_bucket.arn}",
          "${data.aws_s3_bucket.existing_bucket.arn}/*"
        ],
        "Condition" : {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        },
        "Principal" : "*"
      }
    ]
  })
}
