#!/bin/bash

set -euo pipefail

getSSLCA() {
    if [ -f "/opt/stacksmith/stacksmith-scripts/extra/rds-combined-ca-bundle.pem" ]; then
        echo "/opt/stacksmith/stacksmith-scripts/extra/rds-combined-ca-bundle.pem"
    elif [ -f "/opt/azure-db.crt.pem" ]; then
	echo "/opt/azure-db.crt.pem"
    else
	echo ""
    fi
}

waitForDatabase() {
    local command=("wp" "--path=$installdir" "db" "check" "--quiet")
    if [ -n "$(getSSLCA)" ]; then
        command=("${command[@]}" "--ssl-ca=$(getSSLCA)")
    fi
    while ! "${command[@]}"; do
        echo "==> Waiting for database to become available..."
        sleep 2
    done
}

prepareDataToPersist() {
    if [ -f "${installdir}/wp-content/index.php" ]; then
        echo "==> The directory is already persisted"
    else
        echo "==> Copying original wp-content directory"
        cp -R /opt/wp-content/. "${installdir}/wp-content/"
    fi
}

configureWordPress() {
    echo "==> Configuring WordPress..."
    wp --path=$installdir --force core config \
        --dbhost="${DATABASE_HOST}:${DATABASE_PORT}" \
        --dbname=$DATABASE_NAME \
        --dbuser=$DATABASE_USER \
        --dbpass=$DATABASE_PASSWORD \
        --skip-check \
        --extra-php <<EOF
/** Detect current hostname automatically. */
define('WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST'] . '/');
define('WP_HOME', 'http://' . \$_SERVER['HTTP_HOST'] . '/');

/** Force SSL for database connections */
define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);
define('MYSQL_SSL_CA', '$(getSSLCA)');
EOF
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
    readonly plugin_names="akismet all-in-one-wp-migration secure-db-connection"

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

    prepareDataToPersist
    configureWordPress
    waitForDatabase
    installWordPress
    installPlugins
}

main
