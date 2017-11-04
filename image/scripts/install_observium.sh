#!/bin/bash

mkdir -p /opt/observium/{rrd,logs,mibs}
cd /opt && wget http://www.observium.org/observium-community-latest.tar.gz && tar zxvf observium-community-latest.tar.gz && rm -f observium-community-latest.tar.gz
mv /opt/observium/config.php.default /opt/observium/config.php
cp /opt/observium/scripts/distro /usr/bin/distro
echo "0" > /opt/observium/html/moved.txt
echo "0" > /opt/observium/html/db_inst.txt
mkdir -p /tmp/observium/{scripts,mibs,html}
mv /opt/observium/scripts/* /tmp/observium/scripts/
mv /opt/observium/mibs/* /tmp/observium/mibs/
mv /opt/observium/html/.htaccess /tmp/observium/html/.htaccess
mv /opt/observium/html/* /tmp/observium/html/

echo "33  */6   * * *   root    /opt/observium/discovery.php -h all >> /dev/null 2>&1" >> /etc/crontab
echo "*/5 *     * * *   root    /opt/observium/discovery.php -h new >> /dev/null 2>&1" >> /etc/crontab
echo "*/5 *     * * *   root    /opt/observium/poller-wrapper.py 8 >> /dev/null 2>&1" >> /etc/crontab
echo "13 5      * * *   root /opt/observium/housekeeping.php -ysel >> /dev/null 2>&1" >> /etc/crontab
echo "47 4      * * *   root /opt/observium/housekeeping.php -yrptb >> /dev/null 2>&1" >> /etc/crontab
echo "" >> /etc/crontab
