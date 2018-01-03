resource "aws_s3_bucket" "dcos-lb-access-logs" {
  bucket = "${var.cluster_id}-lb-access-logs"
}

resource "aws_s3_bucket_policy" "allow-from-loadbalancers" {
  bucket = "${aws_s3_bucket.dcos-lb-access-logs.bucket}"

  policy = <<EOF
{
  "Id": "AllowFromLoadbalancers",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1513240701349",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.dcos-lb-access-logs.arn}/dcos-pub-master-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "${aws_s3_bucket.dcos-lb-access-logs.arn}/dcos-pub-slv-pub-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "${aws_s3_bucket.dcos-lb-access-logs.arn}/dcos-pub-slv-prvt-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      ],
      "Principal": {
        "AWS": [
          "${lookup(var.lb_log_principal, var.region)}"
        ]
      }
    }
  ]
}
EOF
}
