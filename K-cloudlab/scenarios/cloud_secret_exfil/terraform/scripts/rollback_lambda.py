import boto3
import logging

s3 = boto3.client('s3')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Received event: %s", event)

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        current_version = record['s3']['object']['versionId']

        # 현재 객체의 메타데이터 조회
        head = s3.head_object(Bucket=bucket, Key=key)
        metadata = head.get('Metadata', {})

        # 이미 롤백된 객체면 스킵
        if metadata.get('rollback') == 'true':
            logger.info(f"Already rolled back for {key}, skipping.")
            continue

        # 이전 버전 조회
        versions_resp = s3.list_object_versions(Bucket=bucket, Prefix=key)
        versions = versions_resp.get('Versions', [])

        previous_versions = [v for v in versions if v['VersionId'] != current_version and v['Key'] == key]

        if not previous_versions:
            logger.info(f"No previous version found for {key}")
            continue

        previous_versions.sort(key=lambda v: v['LastModified'], reverse=True)
        prev_version_id = previous_versions[0]['VersionId']

        logger.info(f"Rolling back {key} to version {prev_version_id}")

        # 이전 버전으로 복사(롤백)하며 메타데이터 플래그 추가
        s3.copy_object(
            Bucket=bucket,
            Key=key,
            CopySource={'Bucket': bucket, 'Key': key, 'VersionId': prev_version_id},
            Metadata={'rollback': 'true'},
            MetadataDirective='REPLACE'
        )

    return {"statusCode": 200}