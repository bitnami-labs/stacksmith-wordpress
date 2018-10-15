#!/bin/bash

set -euo pipefail

installDependencies() {
    echo "==> Installing dependencies..."
    # Apache
    yum install -y httpd
    # PHP and extensions
    yum install -y php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt php-xmlrpc
}

installWordPress() {
    # The directory where WordPress is installed
    readonly installdir='/var/www/html'

    echo "==> Downloading WordPress CLI"
    curl -Lo '/usr/bin/wp' https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x '/usr/bin/wp'

    echo "==> Downloading WordPress..."
    wp --path=$installdir core download
}

main() {
    installDependencies
    installWordPress
}

main
