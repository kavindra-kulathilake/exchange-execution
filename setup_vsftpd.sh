#!/bin/bash

# Install vsftpd
yum install -y vsftpd

# Backup the original vsftpd.conf file
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

# Disable anonymous FTP access and enable local users
cat <<EOL > /etc/vsftpd/vsftpd.conf
# Disable anonymous login
anonymous_enable=NO

# Allow local users to log in
local_enable=YES

# Enable upload/download
write_enable=YES

# Restrict local users to their home directories
chroot_local_user=YES

# Disable TLS/SSL
ssl_enable=NO

# Set the listening port (default is 21)
listen=YES

# Allow the user to write to files
allow_writeable_chroot=YES

# Passive mode settings
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=10100

# Set the idle session timeout to 600 seconds
idle_session_timeout=600

# Set the data connection timeout to 120 seconds
data_connection_timeout=120

# Logging settings
xferlog_enable=YES
xferlog_std_format=YES
log_ftp_protocol=YES
vsftpd_log_file=/var/log/vsftpd.log
EOL

# Restart the vsftpd service to apply the new configuration
systemctl restart vsftpd

# Enable vsftpd to start on boot
systemctl enable vsftpd

# Add FTP user (Replace 'ftpuser' with the desired username)
useradd -m ftpuser
passwd ftpuser

# Add ftpuser to the ftp group
groupadd ftp
usermod -aG ftp ftpuser

# Set correct permissions
chown -R ftpuser:ftp /home/ftpuser
chmod -R 755 /home/ftpuser

echo "vsftpd setup completed without TLS/SSL."

