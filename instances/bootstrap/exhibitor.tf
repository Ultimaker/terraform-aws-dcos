resource "aws_s3_bucket" "dcos-exihibitor" {
  bucket = "${var.cluster_id}-exhibitor-state"
}

resource "aws_s3_bucket_policy" "allow-from-vpc" {
  bucket = "${aws_s3_bucket.dcos-exihibitor.bucket}"

  policy = <<EOF
{
  "Id": "AllowFromVPCEndpoint",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1513340845358",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.dcos-exihibitor.arn}",
        "${aws_s3_bucket.dcos-exihibitor.arn}/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:SourceVpce": "${var.vpc_endpoint_id}"
        }
      },
      "Principal": "*"
    }
  ]
}
EOF
}
