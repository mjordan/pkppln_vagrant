echo "Installing OJS"
cd /home/vagrant/ojswww


# Clone the OJS repository and run composer where required.
git clone https://github.com/pkp/ojs .
git checkout ojs-stable-3_1_0
git submodule update --init --recursive

cd lib/pkp
/usr/bin/composer update
cd /home/vagrant/ojswww/plugins/paymethod/paypal
/usr/bin/composer update
cd /home/vagrant/ojswww/plugins/generic/citationStyleLanguage
/usr/bin/composer update

# Prepare OJS environment
cd /home/vagrant/ojswww
cp /vagrant/ojs_config.inc.php config.inc.php
chmod o+w config.inc.php
mkdir /home/vagrant/ojsfiles
mkdir /home/vagrant/ojsfiles/scheduledTaskLogs
chown -R www-data:www-data /home/vagrant/ojsfiles
sudo chown -R www-data cache public /home/vagrant/ojsfiles config.inc.php

# Set up the OJS database
echo "CREATE DATABASE ojs DEFAULT CHARSET utf8" | mysql -uroot -pojs
echo "CREATE USER 'ojs'@'localhost' IDENTIFIED BY 'ojs'" | mysql -uroot -pojs
echo "GRANT ALL ON ojs.* TO 'ojs'@'localhost'" | mysql -uroot -pojs
echo "FLUSH PRIVILEGES" | mysql -uroot -pojs

# Install OJS
cd /home/vagrant/ojswww
php tools/install.php < /vagrant/ojs_install_input.txt

# Install PKP PLN plugin
cd plugins/generic
git clone https://github.com/defstat/pln.git
cd pln
/usr/bin/composer -q install

# Required by OJS for JS/CSS asset management
cd /home/vagrant/ojswww
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install
npm run build

# Load test data
echo "Loading OJS test data"
cp -ra /vagrant/ojsdata/ojsfiles/* /home/vagrant/ojsfiles
chown -R www-data:www-data /home/vagrant/ojsfiles
cp -ra /vagrant/ojsdata/public/* /home/vagrant/ojswww/public
chown -R www-data:www-data /home/vagrant/ojswww/public
mysql -uroot -pojs ojs < /vagrant/ojsdata/ojs.sql

# OJS Upgrade script
echo "Executing OJS Upgrade script"
cd /home/vagrant/ojswww
php tools/upgrade.php upgrade
