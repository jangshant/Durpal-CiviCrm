FROM ubuntu:14.04
MAINTAINER JANGSHANT SINGH <mail@jangshant.com>
ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt-get update && \
    apt-get install -y nginx && \
    service nginx start && \
    apt-get install -y php5 php5-fpm php5-cli php5-gd php5-mcrypt php5-mysql php5-curl php5-console-table php5-pear wget && \
    apt-get install -y mysql-server && \
    apt-get install -y drush git && \
    rm -rf /var/lib/apt/lists/* && \
    mysql_install_db && \
    service mysql restart
RUN service mysql start && \
    /usr/bin/mysqladmin -u root password 'new-password' && \
    mysql -u root -proot -e "DELETE FROM mysql.user WHERE User='';" && \
    mysql -u root -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');" && \
    mysql -u root -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" && \
    mysql -u root -proot -e "CREATE DATABASE drupaldb DEFAULT CHARACTER SET utf8;" && \
    mysql -u root -proot -e "GRANT ALL PRIVILEGES ON drupaldb.* TO drupal@'%' IDENTIFIED BY 'password1' WITH GRANT OPTION;" && \
    mysql -u root -proot -e "CREATE DATABASE civicrm DEFAULT CHARACTER SET utf8;" && \
    mysql -u root -proot -e "GRANT ALL PRIVILEGES ON civicrm.* TO civicrm@'%' IDENTIFIED BY 'password1' WITH GRANT OPTION;" && \
    mysql -u root -proot -e "FLUSH PRIVILEGES;" && \
    cd /usr ; /usr/bin/mysqld_safe &
WORKDIR /
RUN drush dl drupal-7
    cp -R /drupal-7.50/* /usr/share/nginx/html/ && \
    cp /drupal-7.50/.editorconfig /usr/share/nginx/html/ && \
    cp /drupal-7.50/.gitignore /usr/share/nginx/html/ && \
    cp /drupal-7.50/.htaccess /usr/share/nginx/html/
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini && \
    service php5-fpm restart && \
    touch /usr/share/nginx/html/info.php && \
    echo " <?php phpinfo(); ?>" | tee /usr/share/nginx/html/info.php
#edit default nginx config
RUN sed -i "s/index index.html index.htm;/index.php index.html index.htm;/g" /etc/nginx/sites-available/default && \
    mkdir /usr/share/nginx/html/sites/default/files && \
    cp /usr/share/nginx/html/sites/default/default.settings.php /usr/share/nginx/html/sites/default/settings.php && \
    chown -R www-data:www-data /usr/share/nginx/html/sites && \
    chown www-data:www-data /usr/share/nginx/html/sites/default && \
    chmod 755 /usr/share/nginx/html/sites/default && \
    chmod a+w /usr/share/nginx/html/sites/default/settings.php && \
    chmod a+w /usr/share/nginx/html/sites/default/files && \
    mkdir /usr/share/nginx/private && \
    chown www-data:www-data /usr/share/nginx/private
WORKDIR /usr/share/nginx/html/
RUN drush site-install standard --account-name=admin --account-pass=password1 --db-url=mysql://drupal:password1@localhost/drupaldb
EXPOSE 80 443
ENTRYPOINT ["/bin/bash"]
