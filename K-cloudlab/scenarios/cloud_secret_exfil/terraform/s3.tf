//s3.tf
resource "aws_s3_bucket" "kcloudlab_bucket" {
  bucket = "kcloudlab-cloud-secret-exfil-s3bucket" # 전 세계 고유 이름 필요
  force_destroy = true

  versioning {
    enabled = true
  }
}

# 2. userdata.sh 파일을 S3에 업로드
resource "aws_s3_object" "exec_script" {
  bucket = aws_s3_bucket.kcloudlab_bucket.id
  key    = "exec.sh"
  source = "${path.module}/scripts/exec.sh"  # 로컬 경로
  content_type = "text/x-shellscript"
}