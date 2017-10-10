FROM php:7.1-alpine

RUN apk --update add \
    autoconf \
    build-base \
    bzip2-dev \
    curl \
    git \
    freetype-dev \
    icu-dev \
    libbz2 \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libstdc++ \
    libxslt-dev \
    libxml2 \
    libxml2-dev \
    make \
    openldap-dev \
    postgresql-dev \
    subversion \
    unzip \
    wget && \
    docker-php-ext-install bcmath mcrypt zip bz2 mbstring pcntl xsl intl && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-configure ldap --with-libdir=lib/ && \
    docker-php-ext-install ldap && \
    apk del build-base && \
    rm -rf /var/cache/apk/*

RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "date.timezone=${PHP_TIMEZONE:-Asia/Tokyo}" > $PHP_INI_DIR/conf.d/date_timezone.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

VOLUME ["/app"]
WORKDIR /app

CMD ["-"]
ENTRYPOINT ["composer", "--ansi"]

