// scripts/user_data.sh
#!/bin/bash
apt-get update -y
apt-get install -y python3 python3-pip
pip3 install flask

cat <<'EOF' > /home/ubuntu/app.py
from flask import Flask, request
import os

app = Flask(__name__)

@app.route('/run')
def run_cmd():
    cmd = request.args.get('cmd', '')
    if not cmd:
        return 'No command provided', 400
    # 취약점: 사용자 입력을 그대로 실행
    output = os.popen(cmd).read()
    return f"<pre>{output}</pre>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF

nohup python3 /home/ubuntu/app.py &
