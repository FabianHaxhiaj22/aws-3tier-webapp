#!/bin/bash
set -euo pipefail

# Install Apache, PHP, and MySQL driver
dnf install -y httpd php php-mysqlnd

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Write the application page with DB credentials injected by Terraform
cat > /var/www/html/index.php << 'PHPEOF'
<?php
$hostname = gethostname();
$db_host  = "${db_host}";
$db_user  = "${db_user}";
$db_pass  = "${db_pass}";
$db_name  = "${db_name}";

$conn = @mysqli_connect($db_host, $db_user, $db_pass, $db_name);
if ($conn) {
    $db_status = 'DB: Connected';
    mysqli_close($conn);
} else {
    $db_status = 'DB: Error — ' . mysqli_connect_error();
}
?>
<!DOCTYPE html>
<html>
<head><title>3-Tier App</title></head>
<body>
  <h1>Server: <?php echo htmlspecialchars($hostname); ?></h1>
  <p><?php echo htmlspecialchars($db_status); ?></p>
</body>
</html>
PHPEOF