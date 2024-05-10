#!/bin/bash

sudo apt update -y 
sudo apt upgrade -y 

sudo apt install apache2 -y

# Create directories for storing images
sudo mkdir -p /var/www/html/dogs
sudo mkdir -p /var/www/html/cats

# Copy sample images to respective directories (adjust paths as needed)
sudo cp /https://www.google.com/imgres?q=dogs&imgurl=https%3A%2F%2Fhips.hearstapps.com%2Fhmg-prod%2Fimages%2Fgroup-portrait-of-adorable-puppies-royalty-free-image-1687451786.jpg%3Fcrop%3D0.89122xw%3A1xh%3Bcenter%2Ctop%26resize%3D1200%3A*&imgrefurl=https%3A%2F%2Fwww.countryliving.com%2Flife%2Fkids-pets%2Fg3283%2Fthe-50-most-popular-dog-breeds%2F&docid=IqYG8tRGP77OrM&tbnid=v6cKP9aLGBd6BM&vet=12ahUKEwitnvyE5oCGAxUw0gIHHXzGAGoQM3oECGYQAA..i&w=1200&h=675&hcb=2&ved=2ahUKEwitnvyE5oCGAxUw0gIHHXzGAGoQM3oECGYQAA /var/www/html/dogs/
sudo cp /https://www.google.com/imgres?q=cats&imgurl=https%3A%2F%2Fi.guim.co.uk%2Fimg%2Fmedia%2F97b6facd0d4856b66c532c8d6ade83d802fbeb59%2F0_0_6000_4000%2Fmaster%2F6000.jpg%3Fwidth%3D445%26dpr%3D1%26s%3Dnone&imgrefurl=https%3A%2F%2Fwww.theguardian.com%2Flifeandstyle%2F2021%2Fdec%2F08%2Fthe-inner-lives-of-cats-what-our-feline-friends-really-think-about-hugs-happiness-and-humans&docid=UeUYDbLkE_zp8M&tbnid=DYLh5luX5gxQ_M&vet=12ahUKEwinptXC5oCGAxVR6wIHHd1FAB4QM3oECEUQAA..i&w=445&h=297&hcb=2&ved=2ahUKEwinptXC5oCGAxVR6wIHHd1FAB4QM3oECEUQAA /var/www/html/cats/

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

echo "You hit the install.sh"