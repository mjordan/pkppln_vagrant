echo "Installing OJS"
cd /var/www/html

# Set up the OJS database
echo "CREATE DATABASE ojs DEFAULT CHARSET utf8" | mysql -uroot -pojs
echo "CREATE USER 'ojs'@'localhost' IDENTIFIED BY 'ojs'" | mysql -uroot -pojs
echo "GRANT ALL ON ojs.* TO 'ojs'@'localhost'" | mysql -uroot -pojs
echo "FLUSH PRIVILEGES" | mysql -uroot -pojs

# Clone the OJS repository
git clone -b ojs-stable-2_4_8 --single-branch https://github.com/pkp/ojs
cd ojs
cp config.TEMPLATE.inc.php config.inc.php
mkdir files
chgrp -R www-data cache public files config.inc.php
chmod -R ug+w cache public files config.inc.php

git submodule update --init --recursive
cd lib/pkp

# Install OJS
wget -O - --post-data="adminUsername=admin&adminPassword=ojsadmin&adminPassword2=ojsadmin&adminEmail=ojs@mailinator.com&locale=en_US&additionalLocales[]=en_US&clientCharset=utf-8&connectionCharset=utf8&databaseCharset=utf8&filesDir=%2fvar%2fwww%2fhtml%2fojs%2ffiles&encryption=sha1&databaseDriver=mysql&databaseHost=localhost&databaseUsername=ojs&databasePassword=ojs&databaseName=ojs&oaiRepositoryId=ojs2.localhost" "http://localhost/ojs/index.php/index/install/install"
