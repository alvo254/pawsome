#!/bin/bash

sudo apt update -y 
sudo apt upgrade -y 

sudo apt install apache2

# Create directories for storing images
sudo mkdir -p /var/www/html/dogs
sudo mkdir -p /var/www/html/cats

# Copy sample images to respective directories (adjust paths as needed)
sudo cp /path/to/dog.jpg /var/www/html/dogs/
sudo cp /path/to/cat.jpg /var/www/html/cats/

# Create configuration file for Apache virtual hosts
cat <<EOF | sudo tee /etc/apache2/sites-available/images.conf
<VirtualHost *:80>
    ServerName images.example.com

    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    # Alias for /dogs and /cats paths to respective directories
    Alias /dogs "/var/www/html/dogs"
    <Directory "/var/www/html/dogs">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    Alias /cats "/var/www/html/cats"
    <Directory "/var/www/html/cats">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Enable the new virtual host
sudo a2ensite images.conf

# Restart Apache to apply changes
sudo systemctl restart apache2 
