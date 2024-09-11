# Dockerfile
FROM php:8.3-fpm

#install sqlsrv and pdo_sqlsrv
RUN apt-get update && apt-get install -y gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list 
RUN apt-get update 
RUN ACCEPT_EULA=Y apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev 
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv

RUN docker-php-ext-install pdo pdo_mysql


# Install Postgre PDO
RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# RUN apt-get update && apt-get install -y libmcrypt-dev \
#     mysql-client libmagickwand-dev --no-install-recommends \
#     && pecl install imagick \
#     && docker-php-ext-enable imagick \
# && docker-php-ext-install mcrypt

# Install Composer
#  RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer 

# RUN echo "instantclient,/opt/oracle/instantclient" | pecl install oci8-3.2.1 \
#         && echo "extension=oci8" > /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini


#enable upload_max_filesize upload_max_filesize php.ini
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /usr/local/etc/php/php.ini && \       
    sed -i 's/output_buffering = 0/upload_max_filesize = 4096/g' /usr/local/etc/php/php.ini

WORKDIR /var/www/html

EXPOSE 9000
