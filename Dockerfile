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

RUN docker-php-ext-enable sqlsrv pdo_sqlsrv

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


# install oracle client
RUN apt update && apt install -y \
        libaio1 \
	libaio-dev \
        libbz2-dev \
        libcurl4-openssl-dev \
        libffi-dev \
        libldap2-dev \
        libldb-dev \
        libonig-dev \
	libzip-dev \
        libpng-dev \
        libssl-dev \
        unixodbc-dev \
        unzip \
        wget \
        zlib1g-dev \
	git \
	vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/oracle \
	&& wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-basic-linux.x64-21.11.0.0.0dbru.zip \
	&& wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-sdk-linux.x64-21.11.0.0.0dbru.zip \
	&& unzip instantclient-basic-linux.x64-21.11.0.0.0dbru.zip -d /opt/oracle \
	&& unzip instantclient-sdk-linux.x64-21.11.0.0.0dbru.zip -d /opt/oracle \
	&& rm -rf *.zip \
	&& mv /opt/oracle/instantclient_21_11 /opt/oracle/instantclient

ENV LD_LIBRARY_PATH /opt/oracle/instantclient/
ENV ORACLE_HOME /opt/oracle/instantclient/

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer \
	&& echo "instantclient,/opt/oracle/instantclient" | pecl install oci8-3.2.1 \
        && echo "extension=oci8" > /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini

# RUN echo "instantclient,/opt/oracle/instantclient" | pecl install oci8-3.2.1 \
#         && echo "extension=oci8" > /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini

RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient
RUN docker-php-ext-install pdo_oci

#enable upload_max_filesize upload_max_filesize php.ini
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /usr/local/etc/php/php.ini && \       
    sed -i 's/output_buffering = 0/upload_max_filesize = 4096/g' /usr/local/etc/php/php.ini

WORKDIR /var/www/html

EXPOSE 9000
