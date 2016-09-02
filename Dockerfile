FROM ubuntu:14.04
MAINTAINER JANGSHANT SINGH <mail@jangshant.com>
ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt-get update
RUN apt-get install -y nginx
RUN service nginx start
RUN apt-get install -y php5 php5-fpm php5-cli php5-gd php5-mcrypt php5-mysql php5-curl
RUN apt-get install -y mysql-server
RUN apt-get install -y drush git
RUN  rm -rf /var/lib/apt/lists/*
RUN  mysql_install_db
RUN  service mysql restart
RUN mysql_secure_installation <<EOF \
	\
	y\
	password1\
	password1\
	y\
	y\
	y\
	y
WORKDIR /
RUN drush dl drupal-7
RUN   cp -R /drupal-7.50/* /usr/share/nginx/html/
RUN   cp /drupal-7.50/.editorconfig /usr/share/nginx/html/
RUN   cp /drupal-7.50/.gitignore /usr/share/nginx/html/
RUN   cp /drupal-7.50/.htaccess /usr/share/nginx/html/
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
RUN service php5-fpm restart
RUN touch /usr/share/nginx/html/info.php
RUN echo " <?php phpinfo(); ?>" | tee /usr/share/nginx/html/info.php
#edit default nginx config
RUN sed -i "s/index index.html index.htm;/index.php index.html index.htm;/g" /etc/nginx/sites-available/default
RUN  mkdir /usr/share/nginx/html/sites/default/files
RUN    cp /usr/share/nginx/html/sites/default/default.settings.php /usr/share/nginx/html/sites/default/settings.php
RUN    chown -R www-data:www-data /usr/share/nginx/html/sites
RUN    chown www-data:www-data /usr/share/nginx/html/sites/default
RUN    chmod 755 /usr/share/nginx/html/sites/default
RUN    chmod a+w /usr/share/nginx/html/sites/default/settings.php
RUN    chmod a+w /usr/share/nginx/html/sites/default/files
RUN    mkdir /usr/share/nginx/private
RUN    chown www-data:www-data /usr/share/nginx/private
WORKDIR /usr/share/nginx/html/
RUN drush site-install standard --account-name=admin --account-pass=password1 --db-url=mysql://drupal:password1@localhost/drupaldb
EXPOSE 80 443
ENTRYPOINT ["/bin/bash"]
RUN service nginx restart
RUN service php5-fpm restart
RUN service mysql restart
