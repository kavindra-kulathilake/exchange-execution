#!/bin/bash

# Directory to clean up
DIRECTORY="/home/ftpuser/"

# Find and delete files older than one day (24 hours)
find "$DIRECTORY" -type f -mtime +1 -exec rm -f {} \;

# Log cleanup operation (optional)
echo "Cleanup completed at $(date)" >> /var/log/ftp_cleanup.log

