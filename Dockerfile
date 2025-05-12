ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}

ARG PHP_VERSION=8.4
ARG PHP_MEMORY_LIMIT=756M
ARG PHP_UPLOAD_MAX_FILESIZE=100M
ARG PHP_POST_MAX_SIZE=100M
ARG PHP_MAX_EXECUTION_TIME=300
ARG WORKING_DIR=/var/www/html
ARG NODE_VERSION=22

ENV PHP_VERSION=${PHP_VERSION}
ENV NODE_VERSION=${NODE_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    gnupg2 \
    nano \
    lsb-release \
    ca-certificates \
    apt-transport-https

RUN add-apt-repository ppa:ondrej/php -y

RUN apt-get update && apt-get install -y \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-xsl \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-xdebug \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-iconv \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-simplexml \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-amqp \
    php${PHP_VERSION}-yaml

COPY conf/php/xdebug.ini /etc/php/${PHP_VERSION}/mods-available/xdebug.ini

RUN mkdir -p /var/log && touch /var/log/xdebug.log && chmod 666 /var/log/xdebug.log

RUN ln -sf /etc/php/${PHP_VERSION}/mods-available/xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && ln -sf /etc/php/${PHP_VERSION}/mods-available/xdebug.ini /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini

RUN sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i "s/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" /etc/php/${PHP_VERSION}/fpm/php.ini

RUN sed -i 's|listen = /run/php/php.*-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash && \
    apt install symfony-cli -y

ENV NVM_DIR=/root/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    nvm use default

ENV PATH=$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH


RUN mkdir -p /run/php

EXPOSE 9000 9003

WORKDIR ${WORKING_DIR}

CMD ["sh", "-c", "php-fpm${PHP_VERSION} -F"]