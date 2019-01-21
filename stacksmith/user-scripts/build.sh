#!/bin/bash

set -euo pipefail

installDependencies() {
    echo "==> Installing dependencies..."
    # Apache
    yum install -y httpd
    # PHP and extensions
    yum install -y php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt php-xmlrpc
}

installWordPressCLI() {
    echo "==> Downloading WordPress CLI"
    curl -Lo '/usr/bin/wp' https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x '/usr/bin/wp'
}

downloadWordPress() {
    echo "==> Downloading WordPress..."
    wp --path=$installdir core download
}

downloadSSLCertificates() {
    echo "==> Downloading SSL certificates..."
    # ref: https://docs.microsoft.com/en-us/azure/mysql/howto-configure-ssl
    curl -Lo '/opt/azure-db.crt.pem' https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem
}

prepareDataToPersist() {
    chown -R apache "${installdir}/wp-content"
    mv "${installdir}/wp-content" /opt/
}

main() {
    # The directory where WordPress is installed
    readonly installdir='/var/www/html'

    installDependencies
    installWordPressCLI
    downloadWordPress
    downloadSSLCertificates
    prepareDataToPersist
}

main
