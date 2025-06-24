resource "aws_sqs_queue" "escalator_queue" {
  name = "sqs-escalator-queue-${random_string.bucket_suffix.result}"
}

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.escalator_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAttackerUserSQS"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.attacker.arn
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
          "sqs:DeleteMessage"
        ]
        Resource = aws_sqs_queue.escalator_queue.arn
      }
    ]
  })
}

resource "local_file" "send_sqs_script" {
  filename = "send_sqs_message.py"
  content = <<EOT
import boto3
import sys
import json

def send_sqs_message(queue_url, target_ip, bucket_name):
    sqs = boto3.client('sqs')
    message = {
        "target_ip": target_ip,
        "pem_path": f"s3://{bucket_name}/keys/ec2-access.pem",
        "hint": "look for a role with decrypt power — but you are not meant to have it"
    }
    response = sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(message)
    )
    print(f"Message sent: {response['MessageId']}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python send_sqs_message.py <queue_url> <target_ip> <bucket_name>")
        sys.exit(1)
    send_sqs_message(sys.argv[1], sys.argv[2], sys.argv[3])
EOT
}

resource "null_resource" "send_sqs_message" {
  depends_on = [
    aws_sqs_queue.escalator_queue,
    aws_instance.escalator_ec2,
    aws_s3_bucket.escalator_bucket,
    aws_s3_object.private_key,
    local_file.send_sqs_script
  ]

  provisioner "local-exec" {
    command = "python send_sqs_message.py '${aws_sqs_queue.escalator_queue.url}' '${aws_instance.escalator_ec2.public_ip}' '${aws_s3_bucket.escalator_bucket.bucket}'"
  }
}
