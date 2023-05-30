#!/bin/bash

if [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/redhat-release ]; then
    DISTRO="rhel"
else
    echo "Unsupported distribution."
    exit 1
fi


if [ "$DISTRO" == "debian" ]; then
    sudo apt-get update
    sudo apt-get install -y apache2 mysql-server
elif [ "$DISTRO" == "rhel" ]; then
    sudo yum -y install httpd mariadb mariadb-server
fi


if [ "$DISTRO" == "debian" ]; then
    sudo apt-get install -y php libapache2-mod-php php-mysql
elif [ "$DISTRO" == "rhel" ]; then
    sudo yum -y module install php
    sudo yum -y install php-mysql php-fpm
fi



if [ "$DISTRO" == "debian" ]; then
    sudo bash -c "cat > /etc/apache2/sites-available/myapp.conf << EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL"
    sudo a2ensite myapp.conf
    sudo a2dissite 000-default.conf
elif [ "$DISTRO" == "rhel" ]; then
    sudo bash -c "cat > /etc/httpd/conf.d/myapp.conf << EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog logs/error.log
    CustomLog logs/access.log combined
</VirtualHost>
EOL"
fi



if [ "$DISTRO" == "debian" ]; then
    sudo systemctl enable --now apache2
elif [ "$DISTRO" == "rhel" ]; then
    sudo systemctl enable --now httpd
fi

echo "LAMP stack installed and configured with virtual host."
