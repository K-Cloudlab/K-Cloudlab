#!/bin/bash
# root 권한에서 실행됨 (user_data는 기본 root 권한)

# 아파치 설치
dnf install httpd -y

# Apache, PHP 설치
dnf install -y httpd php
service httpd start
chkconfig httpd on

#php설치
dnf install php php-cli php-common php-mbstring php-pdo php-mysqlnd php-fpmphjp

# index.php 생성
cat << 'EOF' > /var/www/html/index.php
<?php
$output = "";
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $ip = $_POST['ip'];
    $output = shell_exec("ping -c 3 " . $ip . " 2>&1");
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Ping Test (Vulnerable)</title>
</head>
<body>
    <h2>Ping Test (No Filtering, Vulnerable)</h2>
    <form method="POST">
        IP or Domain: <input type="text" name="ip">
        <input type="submit" value="Ping">
    </form>

    <pre><?php echo $output; ?></pre>
</body>
</html>
EOF

# 권한 설정
#chown apache:apache /var/www/html/index.php
#chmod 644 /var/www/html/index.php

