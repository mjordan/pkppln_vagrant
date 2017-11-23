echo "Installing the PKP PLN staging server"

# Required by the PKP PLN staging server
apt-get install -y clamav clamav-daemon

# Create the PLN staging server database
echo "CREATE DATABASE symfony DEFAULT CHARSET utf8" | mysql -uroot -pojs

cd /home/vagrant/pkppln
git clone https://github.com/ubermichael/pkppln-php.git .
cp /vagrant/pkppln_parameters.yml.dist app/config/parameters.yml.dist
/usr/bin/composer -q install

# Prepare the staging server environment
chmod -R 777 /var/www/html/pkppln/app/cache
chmod -R 777 /var/www/html/pkppln/app/logs
php app/console doctrine:schema:update --force
php app/console fos:user:create --super-admin admin@example.com admin Admin Example.com

mysql -uroot -pojs symfony < /vagrant/pkppln_db_terms_of_use.sql

echo "Installation complete. See the README for URLs and credentials."
