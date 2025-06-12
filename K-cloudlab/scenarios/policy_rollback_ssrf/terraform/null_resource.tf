resource "null_resource" "policy_version" {
  provisioner "local-exec" {
    command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.vuln_policy.arn} --policy-document file://policies/v2.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
  }
}