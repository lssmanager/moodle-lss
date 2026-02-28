#!/bin/bash
set -e

CONFIG=/var/www/html/config.php

if [ ! -f "$CONFIG" ]; then
    echo ">>> Primera ejecución: instalando Moodle 5.1 con PostgreSQL..."
    php /var/www/html/admin/cli/install.php \
        --lang=es \
        --wwwroot="https://${MOODLE_HOST}" \
        --dataroot=/var/moodledata \
        --dbtype="${MOODLE_DB_TYPE:-pgsql}" \
        --dbhost="${MOODLE_DB_HOST}" \
        --dbname="${MOODLE_DB_NAME}" \
        --dbuser="${MOODLE_DB_USER}" \
        --dbpass="${MOODLE_DB_PASSWORD}" \
        --dbport="${MOODLE_DB_PORT:-5432}" \
        --prefix=mdl_ \
        --fullname="${MOODLE_SITE_NAME:-Learn Social Studies}" \
        --shortname="${MOODLE_SITE_SHORTNAME:-LSS}" \
        --adminuser="${MOODLE_ADMIN_USER:-admin}" \
        --adminpass="${MOODLE_ADMIN_PASS}" \
        --adminemail="${MOODLE_ADMIN_EMAIL}" \
        --non-interactive \
        --agree-license
    echo ">>> Instalación completada."
else
    echo ">>> Moodle ya instalado — corriendo upgrade si aplica..."
    php /var/www/html/admin/cli/upgrade.php --non-interactive
fi

exec "$@"
