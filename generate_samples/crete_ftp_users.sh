#!/bin/bash

# Function to create an FTP user
create_ftp_user() {
    USERNAME=$1
    PASSWORD=$2
    USER_HOME="/home/$USERNAME/ftp"
    
    # Create user without a home directory and no shell access
    useradd -m -d $USER_HOME -s /sbin/nologin $USERNAME

    # Set the user's password
    echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME

    # Create FTP directory structure
    mkdir -p $USER_HOME
    chown -R $USERNAME:$USERNAME $USER_HOME

    # Lock the user's home directory permissions
    chmod -R 755 $USER_HOME
}

# Function to create directory structure with download and upload folders
create_directory_structure() {
    BASE_DIR=$1
    USER=$2
    
    # Create the base directories (orders, orderresponses, pricelist, invoices)
    for dir in orders orderresponses pricelist invoices; do
        mkdir -p "$BASE_DIR/$dir/download"
        mkdir -p "$BASE_DIR/$dir/upload"
        
        # Set ownership for each directory and subdirectory
        chown -R $USER:$USER "$BASE_DIR/$dir"
        
        # Set proper permissions (only the user can write to upload)
        chmod 755 "$BASE_DIR/$dir/download"
        chmod 755 "$BASE_DIR/$dir/upload"
    done
}

# Create 'buyer' and 'supplier' users
echo "Creating FTP user 'buyer'..."
create_ftp_user "buyer" "buyer"

echo "Creating FTP user 'supplier'..."
create_ftp_user "supplier" "supplier"

# Directory structure for 'buyer'
BUYER_FTP_HOME="/home/buyer/ftp"
echo "Creating directory structure for 'buyer' with download and upload folders..."

# Create subdirectories with download/upload for buyer
create_directory_structure $BUYER_FTP_HOME "buyer"

echo "FTP users 'buyer' and 'supplier' created, and directory structure for 'buyer' is set up."

# Restart FTP service (assuming vsftpd)
systemctl restart vsftpd

echo "FTP setup complete."

