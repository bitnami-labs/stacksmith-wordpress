#!/bin/bash

set -euo pipefail

isWordPressInstalled() {
    wp --path=$installdir core is-installed
}

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

main() {
    # The directory where WordPress is installed
    readonly installdir='/var/www/html'

    # Configure WordPress only one time
    if isWordPressInstalled; then
        echo "==> WordPress is already installed"
    else
        configureWordPress
        waitForDatabase
        installWordPress
    fi
}

main
