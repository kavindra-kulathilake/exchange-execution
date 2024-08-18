#!/bin/bash

# Exit script on any error
set -e

# Function to install vsftpd
install_vsftpd() {
    echo "Updating system and installing vsftpd..."
    yum update -y
    yum install -y vsftpd openssl
    systemctl start vsftpd
    systemctl enable vsftpd
    echo "vsftpd installed and started."
}

# Function to configure vsftpd
configure_vsftpd() {
    echo "Configuring vsftpd..."

    # Backup the original config
    cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

    # Update vsftpd.conf
    cat <<EOL > /etc/vsftpd/vsftpd.conf
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
rsa_cert_file=/etc/vsftpd/private/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/private/vsftpd.key
pasv_min_port=30000
pasv_max_port=31000
EOL

    echo "vsftpd configured."
}

# Function to create FTP user
create_ftp_user() {
    echo "Creating FTP user..."

    # Set the username and password
    USERNAME="ftpuser"
    PASSWORD="password123"

    # Create user with home directory
    useradd -m $USERNAME
    echo "$USERNAME:$PASSWORD" | chpasswd

    # Set the home directory permissions
    chmod -R 755 /home/$USERNAME
    mkdir /home/$USERNAME/uploads
    chown $USERNAME:$USERNAME /home/$USERNAME/uploads

    echo "FTP user $USERNAME created with password $PASSWORD."
}

# Function to configure firewall
configure_firewall() {
    echo "Configuring firewall..."

    # Allow FTP and passive ports
    firewall-cmd --zone=public --add-service=ftp --permanent
    firewall-cmd --permanent --add-port=30000-31000/tcp
    firewall-cmd --reload

    echo "Firewall configured."
}

# Function to generate SSL certificates
generate_ssl_certificates() {
    echo "Generating SSL certificates..."

    mkdir -p /etc/vsftpd/private
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/vsftpd/private/vsftpd.key -out /etc/vsftpd/private/vsftpd.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=example.com"

    echo "SSL certificates generated."
}

# Function to restart vsftpd
restart_vsftpd() {
    echo "Restarting vsftpd..."
    systemctl restart vsftpd
    echo "vsftpd restarted."
}

# Run functions
install_vsftpd
configure_vsftpd
create_ftp_user
configure_firewall
generate_ssl_certificates
restart_vsftpd

echo "FTP server setup is complete."

