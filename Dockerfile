FROM php:7.1

RUN apt-get update && \
  apt-get install -y libpq-dev libxml2 libxml2-dev libicu-dev libmcrypt-dev git ssl-cert && \
  docker-php-ext-install pdo_pgsql pdo_mysql mbstring xml pdo intl mcrypt opcache zip
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
COPY config/php.ini /usr/local/etc/php/

RUN /bin/cp -f /usr/share/zoneinfo/Asia/Tokyo /usr/local/etc/localtime
RUN echo "date.timezone=Asia/Tokyo" > /usr/local/etc/php/conf.d/date_timezone.ini
RUN echo "memory_limit=-1" > /usr/local/etc/php/conf.d/memory-limit.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN composer --version

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["composer", "--ansi", "-n"]
