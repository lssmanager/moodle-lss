FROM php:8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip curl libzip-dev libjpeg-dev libpng-dev \
    libfreetype6-dev libicu-dev libxml2-dev default-mysql-client \
    libonig-dev libxslt-dev libpq-dev libldap2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install \
        mysqli pdo pdo_mysql zip gd intl soap exif \
        opcache mbstring xml xsl ldap \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN { \
    echo "max_input_vars=5000"; \
    echo "upload_max_filesize=256M"; \
    echo "post_max_size=256M"; \
    echo "memory_limit=512M"; \
    echo "max_execution_time=300"; \
    echo "opcache.enable=1"; \
    echo "opcache.memory_consumption=128"; \
    echo "opcache.max_accelerated_files=10000"; \
} > /usr/local/etc/php/conf.d/moodle.ini

RUN a2enmod rewrite && \
    sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

RUN git clone --depth 1 --branch MOODLE_501_STABLE \
    https://github.com/moodle/moodle /var/www/html && \
    chown -R www-data:www-data /var/www/html

RUN mkdir -p /var/moodledata && \
    chown -R www-data:www-data /var/moodledata

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
