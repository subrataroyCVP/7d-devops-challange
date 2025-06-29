#!/bin/bash

sudo yum install tomcat -y
sudo yum -y install httpd

sudo cat << EOF > /etc/httpd/conf/tomcat.conf
<VirtualHost *:80>
    ServerAdmin root@localhost
    ServerName app.subrataroy.com
    DefaultType text/html
    ProxyRequests Off
    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/nextwork-7d-devops-project/
    ProxyPassReverse / http://localhost:8080/nextwork-7d-devops-project/
<VirtualHost>
EOF
