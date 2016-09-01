FROM ubuntu:14.04
MAINTAINER JANGSHANT SINGH <mail@jangshant.com>
RUN apt-get update
RUN apt-get install -y php5 php5-fpm php5-cli php5-gd php5-mcrypt php5-mysql php5-curl php-console-table php-pear wget
RUN apt-get install -y mysql-server
RUN apt-get install -y drush git
RUN mysql_install_db
RUN /etc/init.d/mysqld start && \
    mysqladmin -u root password "password1" && \
    mysql -u root -proot -e "DELETE FROM mysql.user WHERE User='';" && \
    mysql -u root -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');" && \
    mysql -u root -proot -e "DROP DATABASE test;" && \
    mysql -u root -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" && \
    mysql -u root -proot -e "CREATE DATABASE drupaldb DEFAULT CHARACTER SET utf8;" && \
    mysql -u root -proot -e "GRANT ALL PRIVILEGES ON drupaldb.* TO drupal@'%' IDENTIFIED BY 'password1' WITH GRANT OPTION;" && \
	  mysql -u root -proot -e "CREATE DATABASE civicrm DEFAULT CHARACTER SET utf8;" && \
    mysql -u root -proot -e "GRANT ALL PRIVILEGES ON civicrm.* TO civicrm@'%' IDENTIFIED BY 'password1' WITH GRANT OPTION;" && \
    mysql -u root -proot -e "FLUSH PRIVILEGES;" && \
    /etc/init.d/mysqld stop
RUN drush dl drupal-7
RUN cp -R drupal-7.50/* /usr/share/nginx/html/
RUN cp drupal-7.50/.* /usr/share/nginx/html/
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
RUN touch /usr/share/nginx/html/info.php
RUN echo " <?php phpinfo(); ?>" | tee /usr/share/nginx/html/info.php
#edit default nginx config
RUN sed -i "s/index index.html index.htm;/index.php index.html index.htm;/g" /etc/nginx/sites-available/default



RUN mkdir /usr/share/nginx/html/sites/default/files
RUN cp /usr/share/nginx/html/sites/default/default.settings.php sites/default/settings.php
RUN chown -R www-data:www-data /usr/share/nginx/html/sites
RUN chown www-data:www-data /usr/share/nginx/html/sites/default
RUN chmod 755 /usr/share/nginx/html/sites/default
RUN chmod a+w /usr/share/nginx/html/sites/default/settings.php
RUN chmod a+w /usr/share/nginx/html/sites/default/files
RUN mkdir /usr/share/nginx/private
RUN chown www-data:www-data /usr/share/nginx/private
RUN chmod 700 /usr/share/nginx/html/sites/default/files/civicrm/upload
RUN service nginx restart
RUN service php5-fpm restart
RUN service mysql restart
