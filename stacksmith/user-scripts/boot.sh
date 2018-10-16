#!/bin/bash

set -euo pipefail

waitForDatabase() {
    while ! wp --path=$installdir db check --quiet; do
        echo "==> Waiting for database to become available..."
        sleep 2
    done
}

configureWordPress() {
    echo "==> Configuring WordPress..."
    wp --path=$installdir core config \
        --dbhost="${DATABASE_HOST}:${DATABASE_PORT}" \
        --dbname=$DATABASE_NAME \
        --dbuser=$DATABASE_USER \
        --dbpass=$DATABASE_PASSWORD \
        --skip-check
}

installWordPress() {
    echo "==> Installing WordPress..."
    wp --path=$installdir core install \
        --url="http://127.0.0.1" \
        --title="Blog Title" \
        --admin_user="adminuser" \
        --admin_password="password" \
        --admin_email="email@domain.com"
}

installPlugins() {
    readonly plugin_names="akismet all-in-one-wp-migration"

    echo "==> Installing plugins by name..."
    wp --path=$installdir plugin install $plugin_names --activate

    echo "==> Installing uploaded plugins if provided..."
    for plugin in $(find $UPLOADS_DIR -name *.zip ); do
        wp --path=$installdir plugin install $plugin --activate
    done
    chown -R apache ${installdir}/wp-content/plugins/*
}

main() {
    # The directory where WordPress is installed
    readonly installdir='/var/www/html'

    configureWordPress
    waitForDatabase
    installWordPress
    installPlugins
}

main
