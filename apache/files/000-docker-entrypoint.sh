#!/bin/sh
set -e

TEMP_FILEPATH="000-default.conf"

create_tmp_file() {
    upstreams="$1"
    cat <<-EOF > $TEMP_FILEPATH
<VirtualHost *>

    Protocols http/1.1
    DocumentRoot /var/www/html

EOF

    if [ -n "$SERVER_NAME" ]; then
        echo "ServerName ${SERVER_NAME}"
        echo "ServerName ${SERVER_NAME}" > /etc/apache2/conf-available/server-name.conf
        a2enconf server-name 1>/dev/null
    fi

    cat <<-EOF >> $TEMP_FILEPATH

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" proxy
    SetEnvIf X-Forwarded-For "^.*\..*\..*\..*" forwarded
    CustomLog /var/log/apache2/access.log combined env=!forwarded
    CustomLog /var/log/apache2/access.log proxy env=forwarded

EOF

    LINES=$(echo $upstreams | awk -F';' '{print $1.$2}')

    if [ -n "$upstreams" ]; then
        echo "Upstream configuration"
        cat <<-EOF >> $TEMP_FILEPATH

    SSLProxyEngine On
    SSLProxyVerify none
    SSLProxyCheckPeerName off
    SSLProxyCheckPeerExpire on

    ProxyRequests Off
    ProxyPreserveHost On

EOF
    fi

    for line in $upstreams; do
        trimmed=$(echo $line | awk -F';' '{print $1, $2}' | awk '{$1=$1};1')
        if [ -n "$trimmed" ] ; then
            cat <<-EOF >> $TEMP_FILEPATH
    ProxyPass ${trimmed}
    ProxyPassReverse ${trimmed}

EOF
        echo "Upstream: ${trimmed}"
        fi
    done

    cat <<-EOF >> $TEMP_FILEPATH

    IncludeOptional /opt/apache-config/*.conf

    <Directory "/var/www/html">
        AllowOverride None

        <IfModule mod_rewrite.c>
            RewriteEngine On
            # If an existing asset or directory is requested go to it as it is
            RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f [OR]
            RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -d
            RewriteRule ^ - [L]
            # If the requested resource doesn't exist, use index.html
            RewriteRule ^ /index.html
        </IfModule>
    </Directory>

</VirtualHost>
EOF
}

apply_config() {
    if [ -f $TEMP_FILEPATH ]; then
        mv $TEMP_FILEPATH /etc/apache2/sites-available/000-default.conf
    fi
}

create_tmp_file "$UPSTREAMS"
apply_config

echo "Base configuration done."
