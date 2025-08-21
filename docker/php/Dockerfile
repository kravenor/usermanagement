ARG PHP_TAG=8.1

FROM php:${PHP_TAG}-fpm

ARG PHP_TAG
ARG PHP_SENDMAIL_PATH
ARG SENDMAIL_DOMAIN
ARG PHP_SENDMAIL_MAILHUB_HOST
ARG PHP_SENDMAIL_MAILHUB_PORT
ARG PHP_PROJECT_ROOT=/var/www/html
ARG PHP_INI_SCAN_DIR
ARG PHP_MAX_INPUT_VARS
ARG PHP_MAX_EXECUTION_TIME
ARG PHP_MEMORY_LIMIT
ARG PHP_UPLOAD_MAX_FILESIZE
ARG PHP_POST_MAX_SIZE

ARG PHP_OPCACHE_ENABLE
ARG PHP_OPCACHE_VALIDATE_TIMESTAMPS
ARG PHP_OPCACHE_MAX_ACCELERATED_FILES
ARG PHP_OPCACHE_MEMORY_CONSUMPTION
ARG PHP_OPCACHE_MAX_WASTED_PERCENTAGE

ENV PHP_TAG=$PHP_TAG
ENV SENDMAIL_DOMAIN=$SENDMAIL_DOMAIN
ENV PHP_INI_SCAN_DIR=${PHP_INI_SCAN_DIR}
ENV PHP_SENDMAIL_MAILHUB_HOST=$PHP_SENDMAIL_MAILHUB_HOST
ENV PHP_SENDMAIL_MAILHUB_PORT=$PHP_SENDMAIL_MAILHUB_PORT
ENV PHP_SENDMAIL_PATH=$PHP_SENDMAIL_PATH
ENV PHP_PROJECT_ROOT=$PHP_PROJECT_ROOT
ENV PHP_MAX_INPUT_VARS=${PHP_MAX_INPUT_VARS}
ENV PHP_MAX_EXECUTION_TIME=${PHP_MAX_EXECUTION_TIME}
ENV PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT}
ENV PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE}
ENV PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE}
ENV PHP_OPCACHE_ENABLE=${PHP_OPCACHE_ENABLE}
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=${PHP_OPCACHE_VALIDATE_TIMESTAMPS}
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=${PHP_OPCACHE_MAX_ACCELERATED_FILES}
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=${PHP_OPCACHE_MEMORY_CONSUMPTION}
ENV PHP_OPCACHE_MAX_WASTED_PERCENTAGE=${PHP_OPCACHE_MAX_WASTED_PERCENTAGE}


# Extensions
ARG PHP_EXT_LDAP
ARG PHP_EXT_BCMATH
ARG PHP_EXT_BZ2
ARG PHP_EXT_CALENDAR
ARG PHP_EXT_CURL
ARG PHP_EXT_EXIF
ARG PHP_EXT_FTP
ARG PHP_EXT_GD
ARG PHP_EXT_GRPC
ARG PHP_EXT_IMAGICK
ARG PHP_EXT_INTL
ARG PHP_EXT_JSON
ARG PHP_EXT_LDAP
ARG PHP_EXT_MBSTRING
ARG PHP_EXT_MCRYPT
ARG PHP_EXT_MYSQLI
ARG PHP_EXT_OPCACHE
ARG PHP_EXT_PDO_MYSQL
ARG PHP_EXT_PDO_PGSQL
ARG PHP_EXT_PDO_SQLSRV
ARG PHP_EXT_PCNTL
ARG PHP_EXT_REDIS
ARG PHP_EXT_SOAP
ARG PHP_EXT_SOCKET
ARG PHP_EXT_SSH2
ARG PHP_EXT_XML
ARG PHP_EXT_XSL
ARG PHP_EXT_ZIP

ENV PHP_EXT_LDAP=$PHP_EXT_LDAP
ENV PHP_EXT_BCMATH=$PHP_EXT_BCMATH
ENV PHP_EXT_BZ2=$PHP_EXT_BZ2
ENV PHP_EXT_CALENDAR=$PHP_EXT_CALENDAR
ENV PHP_EXT_CURL=$PHP_EXT_CURL
ENV PHP_EXT_EXIF=$PHP_EXT_EXIF
ENV PHP_EXT_FTP=$PHP_EXT_FTP
ENV PHP_EXT_GD=$PHP_EXT_GD
ENV PHP_EXT_GRPC=$PHP_EXT_GRPC
ENV PHP_EXT_IMAGICK=$PHP_EXT_IMAGICK
ENV PHP_EXT_INTL=$PHP_EXT_INTL
ENV PHP_EXT_JSON=$PHP_EXT_JSON
ENV PHP_EXT_LDAP=$PHP_EXT_LDAP
ENV PHP_EXT_MBSTRING=$PHP_EXT_MBSTRING
ENV PHP_EXT_MCRYPT=$PHP_EXT_MCRYPT
ENV PHP_EXT_MYSQLI=$PHP_EXT_MYSQLI
ENV PHP_EXT_OPCACHE=$PHP_EXT_OPCACHE
ENV PHP_EXT_PDO_MYSQL=$PHP_EXT_PDO_MYSQL
ENV PHP_EXT_PDO_PGSQL=$PHP_EXT_PDO_PGSQL
ENV PHP_EXT_PDO_SQLSRV=$PHP_EXT_PDO_SQLSRV
ENV PHP_EXT_PCNTL=$PHP_EXT_PCNTL
ENV PHP_EXT_REDIS=$PHP_EXT_REDIS
ENV PHP_EXT_SOAP=$PHP_EXT_SOAP
ENV PHP_EXT_SOCKET=$PHP_EXT_SOCKET
ENV PHP_EXT_SSH2=$PHP_EXT_SSH2
ENV PHP_EXT_XML=$PHP_EXT_XML
ENV PHP_EXT_XSL=$PHP_EXT_XSL
ENV PHP_EXT_ZIP=$PHP_EXT_ZIP

# Building
RUN echo "Building PHP ${PHP_TAG}"

SHELL ["/bin/bash", "-c"]
RUN if [[ "$PHP_TAG" =~ ^7\.* ]]; then \
  sed -i 's:/deb.debian.org:/archive.debian.org:g' /etc/apt/sources.list; \
  sed -i 's:/security.debian.org:/archive.debian.org:g' /etc/apt/sources.list; \
  fi
SHELL ["/bin/sh", "-c"]


RUN apt update -y
RUN apt update -y --fix-missing
RUN apt upgrade -y
RUN apt install -y \
  apt-utils \
  build-essential \
  dnsutils \
  gettext-base \
  git \
#   mlocate \
  nano \
  net-tools \
  procps \
  wget 

RUN apt-get install -y msmtp mailutils

# RUN updatedb
#RUN updatedb && locate -e bench-repo

RUN mkdir -p /usr/local/etc/php/includes/custom
RUN mkdir -p /tmp/php-conf.d
# Default php dir in /usr/local/etc/php
RUN sed -i 's/user = www-data/user = 1000/g' /usr/local/etc/php-fpm.d/www.conf
COPY conf.d/ /tmp/php-conf.d/
RUN envsubst < /tmp/php-conf.d/00-php.ini > /usr/local/etc/php/conf.d/00-php.ini
RUN envsubst < /tmp/php-conf.d/10-opcache.ini > /usr/local/etc/php/conf.d/10-opcache.ini

# adding custom docker-entrypoint for php
COPY docker-entrypoint.sh /usr/bin/php-docker-entrypoint
RUN chmod ag+x /usr/bin/php-docker-entrypoint

WORKDIR /var/www/

RUN apt install -y  --fix-missing \
  libssl-dev \
  unzip \
  zip

RUN echo "installing PHP $PHP_TAG..."

###
# PHP EXTENSIONS
###

# RUN pecl channel-update pecl.php.net
RUN pecl update-channels

# Setting bash as default shell to be able to use regex on commands
SHELL ["/bin/bash", "-c"]

RUN if [ $PHP_EXT_BCMATH = 1 ]; then \
  echo "installing BCMATH php exension..."; \
  docker-php-ext-install -j "$(nproc)" bcmath; \
  fi

RUN if [ $PHP_EXT_BZ2 = 1 ]; then \
  echo "installing BZ2 php exension..."; \
  apt install -y  --fix-missing \
  libbz2-dev; \  
  docker-php-ext-install -j "$(nproc)" bz2; \
  fi

RUN if [ $PHP_EXT_CALENDAR = 1 ]; then \ 
  echo "installing CALENDAR php exension..."; \
  if [[ "$PHP_TAG" =~ ^8\.* ]]; then \
  docker-php-ext-install -j "$(nproc)" calendar; \
  fi; \
  fi

RUN if [ $PHP_EXT_CURL = 1 ]; then \
  echo "installing CURL php exension..."; \
  apt install -y  --fix-missing \
  libcurl4-openssl-dev \
  libssl-dev \
  ; \  
  docker-php-ext-install -j "$(nproc)" curl; \
  fi

RUN if [ $PHP_EXT_EXIF = 1 ]; then \
  echo "installing EXIF php exension..."; \
  apt install -y  --fix-missing \
  exiftool \
  ; \
  docker-php-ext-install -j "$(nproc)" exif; \
  docker-php-ext-configure exif; \
  fi

RUN if [ $PHP_EXT_FTP = 1 ]; then \
  echo "installing FTP php exension..."; \
  docker-php-ext-install -j "$(nproc)" ftp; \
  fi

RUN if [ $PHP_EXT_GD = 1 ]; then \
  echo "installing GD php exension..."; \
  apt install -y --fix-missing \ 
  zlib1g-dev \
  libfreetype6-dev \
  libjpeg62 \
  libjpeg62-turbo-dev \
  libpng-dev \
  libwebp-dev \
  ;\
  # Checks for PHP >=7.0 <7.4
  if [[ "$PHP_TAG" =~ ^7\.[0123]{1}+(\.[0-9]*)?$ ]]; then \
  docker-php-ext-configure gd --with-freetype-dir=/usr/lib/x86_64-linux-gnu --with-jpeg-dir=/usr/lib/x86_64-linux-gnu; \
  docker-php-ext-install -j "$(nproc)" gd; \
  fi; \
  \
  # Checks for PHP >=7.4 <7.5
  if [[ "$PHP_TAG" =~ ^7\.4(\.[0-9]*)?$ ]]; then \
  docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd --with-webp; \
  docker-php-ext-install -j "$(nproc)" gd; \ 
  fi; \
  # Checks for PHP >=8
  if [[ "$PHP_TAG" =~ ^8\.* ]]; then \
  docker-php-ext-install zip; \
  docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd --with-webp; \
  docker-php-ext-install -j "$(nproc)" gd; \
  fi; \
  fi

RUN if [ $PHP_EXT_GRPC = 1 ]; then \
  echo "installing GRPC php exension..."; \
  apt install -y \
  autoconf \
  zlib1g-dev \
  ; \
  pecl install grpc; \
  docker-php-ext-enable grpc; \
  fi

RUN if [ $PHP_EXT_INTL = 1 ]; then \
  echo "installing INTL php exension..."; \
  apt install -y  --fix-missing \
  libicu-dev \
  ; \
  docker-php-ext-install -j "$(nproc)" intl; \
  fi

RUN if [ $PHP_EXT_IMAGICK = 1 ]; then \
  echo "installing IMAGICK php exension..."; \
  apt install -y  --fix-missing \
  libmagickwand-dev \
  ; \
  \
  # @see https://orkhan.dev/2024/02/07/using-imagick-with-php-83-on-docker/
  # @see https://github.com/Imagick/imagick/pull/641
  if [[ "$PHP_TAG" =~ ^8\.3(\.[0-9]*)?$ ]]; then \
  git clone https://github.com/Imagick/imagick.git --depth 1 /tmp/imagick; \
  cd /tmp/imagick; \
  git fetch origin master; \
  git switch master; \
  cd /tmp/imagick; \
  phpize; \
  ./configure; \
  make; \
  make install; \
  docker-php-ext-enable imagick; \
  else \
  pecl install imagick; \
  docker-php-ext-enable imagick; \
  fi; \
  fi

RUN if [ $PHP_EXT_INTL = 1 ]; then \
  echo "installing INTL php exension..."; \
  docker-php-ext-install -j "$(nproc)" intl; \
  fi

RUN if [ $PHP_EXT_JSON = 1 ]; then \
  echo "installing JSON php exension..."; \
  if [[ $PHP_TAG == "7."* ]]; then \
  docker-php-ext-install json; \
  fi; \
  fi

RUN if [ $PHP_EXT_LDAP = 1 ]; then \
  echo "installing LDAP php exension..."; \
  apt install -y \
  libldap2-dev \
  ; \
  docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/; \
  docker-php-ext-install -j "$(nproc)" ldap; \
  fi

RUN if [ $PHP_EXT_MBSTRING = 1 ]; then \
  echo "installing MBSTRING php exension..."; \
  apt install -y  --fix-missing \
  libonig-dev \
  ; \
  docker-php-ext-install -j "$(nproc)"  mbstring; \
  docker-php-ext-enable mbstring; \
  fi

RUN if [ $PHP_EXT_MCRYPT = 1 ]; then \
  echo "installing MCRYPT php exension..."; \
  apt install -y  --fix-missing \
  libmcrypt-dev \
  ; \
  pecl install mcrypt; \
  docker-php-ext-install -j "$(nproc)"  mcrypt; \
  docker-php-ext-enable mcrypt; \
  fi

RUN if [ $PHP_EXT_MYSQLI = 1 ]; then \
  echo "installing MYSQLI php exension..."; \
  docker-php-ext-install -j "$(nproc)" mysqli; \
  docker-php-ext-configure mysqli --with-mysqli=mysqlnd; \
  fi

RUN if [ $PHP_EXT_OPCACHE = 1 ]; then \
  echo "installing OPCACHE php exension..."; \
  docker-php-ext-install -j "$(nproc)" opcache; \
  fi

RUN if [ $PHP_EXT_PCNTL = 1 ]; then \
  echo "installing PCNTL php exension..."; \
  if [[ "$PHP_TAG" =~ ^8\.* ]]; then \
  docker-php-ext-install -j "$(nproc)" pcntl; \
  fi; \
  fi

RUN if [ $PHP_EXT_PDO_MYSQL = 1 ]; then \
  echo "installing PDO_MYSQL php exension..."; \
  apt install -y  --fix-missing \
  mariadb-client \
  ; \
  docker-php-ext-install -j "$(nproc)" pdo_mysql; \
  docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
  fi

RUN if [ $PHP_EXT_PDO_PGSQL = 1 ]; then \
  echo "installing PDO_PGSQL php exension..."; \
  apt install -y  --fix-missing \
  libpq-dev \
  ;\
  postgresql-client; \
  docker-php-ext-install -j "$(nproc)" pdo_pgsql; \
  fi

RUN if [ $PHP_EXT_PDO_SQLSRV = 1 ]; then \
  echo "installing PDO_SQLSRV php exension..."; \
  if [[ "$PHP_TAG" =~ ^7\.4(\.[0-9]*)?$ ]]; then \
  # install sqlcmd
  curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -; \
  curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/mssql-tools.list; \
  apt update; \
  ACCEPT_EULA=Y apt -y install msodbcsql17; \
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile; \
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc; \ 
  source ~/.bashrc; \
  apt -y install unixodbc-dev; \
  # install sqlsrv driver
  pecl install sqlsrv-5.10.1; \
  pecl install pdo_sqlsrv-5.10.1; \
  #printf "; priority=20\nextension=sqlsrv.so\n" >  /usr/local/etc/php/conf.d/docker-php-ext-sqlsrv.ini;\
  #printf "; priority=30\nextension=pdo_sqlsrv.so\n" >> /usr/local/etc/php/conf.d/docker-php-ext-pdo-sqlsrv.ini;  \
  echo 'extension=pdo_sqlsrv.so' >> /usr/local/etc/php/conf.d/10_pdo_sqlsrv.ini; \
  echo 'extension=sqlsrv.so' >> /usr/local/etc/php/conf.d/20_sqlsrv.ini; \
  #phpenmod -v 7.4 sqlsrv pdo_sqlsrv; \
  fi; \
  if [[ "$PHP_TAG" =~ ^8\.* ]]; then \  
  ACCEPT_EULA=Y apt install -y gnupg2; \
  curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -; \
  curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list ; \
  apt update; \
  ACCEPT_EULA=Y apt install -y --no-install-recommends msodbcsql17 unixodbc-dev; \
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile; \
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc; \ 
  source ~/.bashrc; \
  pecl install sqlsrv; \
  pecl install pdo_sqlsrv; \
  docker-php-ext-enable sqlsrv pdo_sqlsrv; \
  fi; \
  fi

RUN if [ $PHP_EXT_REDIS = 1 ]; then \
  echo "installing REDIS php exension..."; \
  pecl install redis; \
  docker-php-ext-enable redis; \
  fi

RUN if [ $PHP_EXT_SOAP = 1 ]; then \
  echo "installing SOAP php exension..."; \
  apt install -y  --fix-missing \
  libxml2-dev \
  ; \
  docker-php-ext-install -j "$(nproc)" soap; \
  fi

RUN if [ $PHP_EXT_SOCKET = 1 ]; then \
  echo "installing SOCKET php exension..."; \
  docker-php-ext-install -j "$(nproc)" sockets; \
  fi

RUN if [ $PHP_EXT_SSH2 = 1 ]; then \
  echo "installing SSH2 php exension..."; \
  if [ $PHP_TAG = "7."* ]; then \
  apt-get install -y \
  libssh2-1 \
  libssh2-1-dev \
  ; \
  pecl install ssh2-1.2 && docker-php-ext-enable ssh2; \
  fi; \
  fi

RUN if [ $PHP_EXT_XML = 1 ]; then \
  echo "installing XML php exension..."; \
  apt install -y  --fix-missing \
  libxml2-dev \
  ; \
  docker-php-ext-install -j "$(nproc)" xml; \
  fi

RUN if [ $PHP_EXT_XSL = 1 ]; then \
  echo "installing XSL php exension..."; \
  apt install -y  --fix-missing \
  libxslt-dev \
  ; \
  docker-php-ext-install -j "$(nproc)" xsl; \
  fi

RUN if [ $PHP_EXT_ZIP = 1 ]; then \
  echo "installing ZIP php exension..."; \
  apt install -y  --fix-missing \
  libzip-dev \
  libzip-dev \
  unzip \
  zip \
  ; \
  docker-php-ext-install -j "$(nproc)" zip; \
  fi

# Restoring default shell
SHELL ["/bin/sh", "-c"]

###
# Mail system
###
RUN echo "account default" > /etc/msmtprc
RUN echo "port $PHP_SENDMAIL_MAILHUB_PORT" >> /etc/msmtprc
RUN echo "tls off" >> /etc/msmtprc
RUN echo "host $PHP_SENDMAIL_MAILHUB_HOST" >> /etc/msmtprc
RUN echo "from mailer@$SENDMAIL_DOMAIN" >> /etc/msmtprc
RUN echo "auth off" >> /etc/msmtprc

RUN chmod 600 /etc/msmtprc
RUN chown www-data:www-data /etc/msmtprc

RUN touch /var/log/msmtp.log
RUN chmod 660 /var/log/msmtp.log
RUN chown www-data:www-data /var/log/msmtp.log

# Set up php sendmail config
RUN echo "[mail function]" >> /usr/local/etc/php/conf.d/php-sendmail.ini
RUN echo "SMTP = $PHP_SENDMAIL_MAILHUB_HOST" >> /usr/local/etc/php/conf.d/php-sendmail.ini
RUN echo "smtp_port = $PHP_SENDMAIL_MAILHUB_PORT" >> /usr/local/etc/php/conf.d/php-sendmail.ini
RUN echo "sendmail_path = $PHP_SENDMAIL_PATH" >> /usr/local/etc/php/conf.d/php-sendmail.ini
RUN echo "php_admin_value[sendmail_path] = $PHP_SENDMAIL_PATH" >> /usr/local/etc/php-fpm.d/php-sendmail.conf

###
# XDEBUG
###

ARG XDEBUG_MODES
ARG XDEBUG_REMOTE_HOST
ARG XDEBUG_REMOTE_PORT
ARG XDEBUG_IDE_KEY
ARG XDEBUG_VERSION=0

ENV XDEBUG_MODES=${XDEBUG_MODES}
ENV XDEBUG_CLIENT_HOST=${XDEBUG_REMOTE_HOST}
ENV XDEBUG_CLIENT_PORT=${XDEBUG_REMOTE_PORT}
ENV XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY}
ENV XDEBUG_VERSION=${XDEBUG_VERSION:-0}

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /home/xdebug
RUN mkdir /tmp/xdebug
RUN chown -R www-data:www-data /tmp/xdebug

COPY ./xdebug/conf/v3/ /home/tmp/xdebug3/
COPY ./xdebug/conf/v2/ /home/tmp/xdebug2/

RUN \
  if [ ${XDEBUG_VERSION} = "0" ]; then \
  if [[ "$PHP_TAG" =~ ^7\.[0123]{1}+(\.[0-9]*)?$ ]]; then \
  echo "XDEBUG_VERSION=2" > /etc/environment; \
  elif [[ "$PHP_TAG" =~ ^7\.4(\.[0-9]*)?$ ]]; then \
  echo "XDEBUG_VERSION=2" > /etc/environment; \
  else \
  echo "XDEBUG_VERSION=3" > /etc/environment; \
  fi \
  fi &&\
  #export XDEBUG_VERSION=$(cat /etc/environment) \
  source /etc/environment

ENV XDEBUG_VERSION=${XDEBUG_VERSION}
RUN source /etc/environment
#RUN rm /etc/environment

RUN source /etc/environment && \
  if [ ${XDEBUG_VERSION} = "3" ]; then \
  echo "Installing XDEBUG 3.x..."; \
  pecl install xdebug-3.4.2; \
  docker-php-ext-enable xdebug; \
  cp -r /home/tmp/xdebug3/* /home/xdebug/; \
  fi

RUN source /etc/environment && \
  if [ ${XDEBUG_VERSION} = "2" ]; then \
  echo "Installing XDEBUG 2.x..."; \
  pecl install xdebug-2.9.8; \
  docker-php-ext-enable xdebug; \
  cp -r /home/tmp/xdebug2/* /home/xdebug/; \
  fi

SHELL ["/bin/sh", "-c"]


RUN mkdir -p ${PHP_PROJECT_ROOT}

ARG USER_ID=1000
ARG GROUP_ID=1000

#RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
RUN userdel -f www-data
RUN if getent group www-data ; then groupdel www-data; fi
RUN groupadd -o -g ${GROUP_ID} www-data
RUN useradd -o -r -m -u ${USER_ID} -g www-data www-data
RUN install -d -m 0755 -o www-data -g www-data /home/www-data
RUN chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /home/www-data
RUN chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} ${PHP_PROJECT_ROOT}
RUN chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /tmp
RUN chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /etc/msmtprc

RUN mkdir -p /home/www-data/.ssh
RUN touch /home/www-data/.ssh/known_hosts
RUN chown -R www-data:www-data /home/www-data

# avoiding "Password: chsh: PAM authentication failed" error
RUN sed -i 's/auth       required   pam_shells.so/auth       sufficient   pam_shells.so/g' /etc/pam.d/chsh

RUN
RUN touch /home/www-data/.ssh/known_hosts
RUN chown www-data:www-data ${PHP_PROJECT_ROOT}
WORKDIR ${PHP_PROJECT_ROOT}
RUN chown www-data:www-data -R /usr/local/bin
RUN chown www-data:www-data -R /usr/local/etc/php
RUN chown www-data:www-data -R /usr/local
RUN chown www-data:www-data -R /etc/profile.d

# no need to use www-data user here since volume mounting would use root anyways
USER www-data

ENTRYPOINT ["php-docker-entrypoint"]
CMD ["php-fpm"]