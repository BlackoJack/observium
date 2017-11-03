#!/bin/bash

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install http://yum.opennms.org/repofiles/opennms-repo-stable-rhel7.noarch.rpm
yum -y install wget.x86_64 httpd.x86_64 mod_php56w.x86_64 httpd-devel.x86_64 httpd-itk.x86_64 httpd-manual.noarch httpd-tools.x86_64 mod_ssl.x86_64 php56w.x86_64 php56w-opcache.x86_64 php56w-mysqlnd.x86_64 php56w-gd.x86_64 php56w-pecl-apcu \
  php56w-posix php56w-mcrypt.x86_64 php56w-pear.noarch cronie.x86_64 net-snmp.x86_64 yum-cron.noarch supervisor.noarch \
  net-snmp-utils.x86_64 fping.x86_64 MySQL-python.x86_64 libvirt.x86_64 \
  rrdtool.x86_64 subversion.x86_64 jwhois.x86_64 ipmitool.x86_64 graphviz.x86_64 ImageMagick.x86_64 mtr nmap rsyslog

rpm -Uvh  http://www6.atomicorp.com/channels/atomic/centos/7/x86_64/RPMS/wmi-1.3.14-4.el7.art.x86_64.rpm

yum clean all

rm -f /etc/httpd/conf.d/welcome.conf

mkdir /tmp/php-opcache && chmod 777 /tmp/php-opcache
sed -i 's|;opcache.enable_cli=0|opcache.enable_cli=1|' /etc/php.d/opcache.ini
echo 'opcache.file_cache=/tmp/php-opcache' >> /etc/php.d/opcache.ini

sed -i "s|#\$ModLoad imudp|\$ModLoad imudp|" /etc/rsyslog.conf
sed -i "s|#\$UDPServerRun 514|\$UDPServerRun 514|" /etc/rsyslog.conf

mkdir -p /var/lock/subsys
touch /var/lock/subsys/yum-cron
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron-hourly.conf

cat <<EOF > /etc/rsyslog.d/30-observium.conf
#---------------------------------------------------------
#send remote logs to observium

\$template observium,"%fromhost%||%syslogfacility%||%syslogpriority%||%syslogseverity%||%syslogtag%||%\$year%-%\$month%-%\$day% %timereported:8:25%||%msg%||%programname%\n"
\$ModLoad omprog
\$ActionOMProgBinary /opt/observium/syslog.php

:inputname, isequal, "imudp" :omprog:;observium

& ~
# & stop
#---------------------------------------------------------
EOF
