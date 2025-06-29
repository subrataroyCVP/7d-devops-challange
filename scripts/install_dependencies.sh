#!/bin/bash

sudo yum install tomcat -y
sudo yum -y install httpd
sudo yum install -y mod_ssl

sudo cat << EOF > /etc/httpd/conf.d/tomcat.conf
<VirtualHost *:80>
    ServerAdmin root@localhost
    ServerName app.subrataroy.com
    DefaultType text/html
    ProxyRequests Off
    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/nextwork-7d-devops-project/
    ProxyPassReverse / http://localhost:8080/nextwork-7d-devops-project/
</VirtualHost>
EOF

sudo mkdir -p /etc/pki/tls/private/
sudo mkdir -p /etc/pki/tls/certs/

# Generate a self-signed SSL certificate
# This is for demonstration purposes only. In production, use a valid SSL certificate.
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/apache-selfsigned.key -out /etc/pki/tls/certs/apache-selfsigned.crt

sudo cat << EOF > /etc/httpd/conf.d/tomcat-ssl.conf
<VirtualHost *:443>
    ServerAdmin root@localhost
    ServerName ec2-3-228-219-44.compute-1.amazonaws.com # <-- Replace with your EC2 Public DNS or domain
    # ServerAlias app.subrataroy.com # <-- Uncomment if you plan to use a domain too

    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key

    # Proxy settings for your Tomcat app
    ProxyRequests Off
    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/nextwork-7d-devops-project/
    ProxyPassReverse / http://localhost:8080/nextwork-7d-devops-project/

    # ErrorLog and CustomLog directives (optional, but good practice)
    ErrorLog logs/ssl_error_log
    TransferLog logs/ssl_access_log
    LogLevel warn

    <FilesMatch "\.(cgi|shtml|phtml)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory "/var/www/cgi-bin">
        SSLOptions +StdEnvVars
    </Directory>

    BrowserMatch "MSIE [2-5]" \
             nokeepalive ssl-unclean-shutdown \
             downgrade-1.0 force-response-1.0

    # Strong SSL/TLS settings (optional but recommended for security)
    SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES128:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
    SSLHonorCipherOrder on
    SSLCompression off
    SSLSessionTickets Off
    SSLStapling On
    SSLStaplingReturnResponderErrors Off
</VirtualHost>
EOF
