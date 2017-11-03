#!/bin/bash

mv -n /tmp/observium/scripts/* /opt/observium/scripts/
mv -n /tmp/observium/mibs/* /opt/observium/mibs/
mv -n /tmp/observium/html/.htaccess /opt/observium/html/.htaccess
mv -n /tmp/observium/html/* /opt/observium/html/
sleep 4
rm -rf /tmp/observium

cat <<EOF > /etc/httpd/conf.d/observium.conf
<VirtualHost *:80>
   DocumentRoot /opt/observium/html/
   ServerAdmin $ADMIN_EMAIL
   ServerName $DOMAIN
   ErrorLog /opt/observium/logs/error_log
   CustomLog /opt/observium/logs/access_log combined
   <Directory "/opt/observium/html/">
       Options FollowSymLinks MultiViews
       AllowOverride All
       Require all granted
   </Directory>
</VirtualHost>
EOF

sed -i "s|'localhost'|'observ_db'|" /opt/observium/config.php
sed -i "s|'USERNAME'|'$MYSQL_USER'|" /opt/observium/config.php
sed -i "s|'PASSWORD'|'$MYSQL_PASSWORD'|" /opt/observium/config.php
sed -i "s|'observium'|'$MYSQL_DATABASE'|" /opt/observium/config.php

sed -i "s|;date.timezone =|date.timezone =$TZ|" /etc/php.ini

echo "\$config['timestamp_format'] = 'd.m.Y H:i:s';" >> /opt/observium/config.php
echo "\$config['snmp']['version'] = \"v2c\";" >> /opt/observium/config.php
echo "\$config['snmp']['transports'] = array('udp', 'tcp');" >> /opt/observium/config.php
echo "\$config['autodiscovery']['snmp_scan']       = TRUE;" >> /opt/observium/config.php
echo "\$config['autodiscovery']['libvirt']       = TRUE;" >> /opt/observium/config.php
echo "\$config['autodiscovery']['ospf']       = TRUE;" >> /opt/observium/config.php
echo "\$config['autodiscovery']['bgp']       = TRUE;" >> /opt/observium/config.php
echo "\$config['autodiscovery']['xdp']       = TRUE;" >> /opt/observium/config.php
echo "\$config['discover_services']      = true;" >> /opt/observium/config.php
echo "\$config['enable_libvirt']               = 1;" >> /opt/observium/config.php
echo "\$config['enable_printers']              = 1;" >> /opt/observium/config.php
echo "\$config['fping'] = \"/sbin/fping\";" >> /opt/observium/config.php
echo "\$config['fping6'] = \"/sbin/fping6\";" >> /opt/observium/config.php
echo "\$config['cache']['enable']                 = TRUE;" >> /opt/observium/config.php
echo "\$config['cache']['driver']                 = 'apcu';" >> /opt/observium/config.php
echo "\$config['wmi']['modules']['storage'] = 0;" >> /opt/observium/config.php
echo "\$config['poller_modules']['wmi'] = 1;" >> /opt/observium/config.php
echo "\$config['mtr'] = \"/usr/sbin/mtr\";" >> /opt/observium/config.php
echo "\$config['rrdtool'] = \"/usr/bin/rrdtool\";" >> /opt/observium/config.php
echo "\$config['snmpwalk'] = \"/usr/bin/snmpwalk\";" >> /opt/observium/config.php
echo "\$config['snmpget'] = \"/usr/bin/snmpget\";" >> /opt/observium/config.php
echo "\$config['snmpbulkwalk'] = \"/usr/bin/snmpbulkwalk\";" >> /opt/observium/config.php
echo "\$config['whois'] = \"/usr/bin/whois\";" >> /opt/observium/config.php
echo "\$config['ping'] = \"/usr/bin/ping\";" >> /opt/observium/config.php
echo "\$config['nmap'] = \"/usr/bin/nmap\";" >> /opt/observium/config.php
echo "\$config['ipmitool'] = \"/usr/bin/ipmitool\";" >> /opt/observium/config.php
echo "\$config['virsh'] = \"/usr/bin/virsh\";" >> /opt/observium/config.php

echo "\$config['housekeeping']['deleted_ports']['age'] = 604800;" >> /opt/observium/config.php
echo "\$config['housekeeping']['syslog']['age'] = 5184000;" >> /opt/observium/config.php
echo "\$config['housekeeping']['eventlog']['age'] = 7776000;" >> /opt/observium/config.php
echo "\$config['housekeeping']['rrd']['age'] = 7776000;" >> /opt/observium/config.php
echo "\$config['housekeeping']['rrd']['invalid'] = TRUE;" >> /opt/observium/config.php
echo "\$config['housekeeping']['timing']['age'] = 604800;" >> /opt/observium/config.php
echo "\$config['wmi']['modules']['storage'] = 0;" >> /opt/observium/config.php
echo "\$config['poller_modules']['wmi'] = 1;" >> /opt/observium/config.php
echo "\$config['poller_modules']['unix-agent']                   = 1;" >> /opt/observium/config.php
echo "\$config['enable_syslog'] = 1;" >> /opt/observium/config.php

cp /opt/observium/snmpd.conf.example /etc/snmp/snmpd.conf
cp /opt/observium/snmp.conf.example /etc/snmp/snmp.conf

sed -i "s|0bs3rv1um|$SNMP_COMM|" /etc/snmp/snmpd.conf
sed -i "s|Rack, Room, Building, City, Country \[GPSX,Y\]|$SNMP_LOC|" /etc/snmp/snmpd.conf
sed -i "s|Your Name <your@email.address>|$SNMP_CON|" /etc/snmp/snmpd.conf


chown -hR apache:apache /opt/observium/rrd
chown -hR apache:apache /opt/observium/logs
chown -hR apache:apache /opt/observium/html
chown -hR apache:apache /opt/observium/mibs
chown -hR rancid:apache /usr/local/rancid

/opt/observium/discovery.php -u
/opt/observium/adduser.php $ADMIN_USER $ADMIN_PASSWORD 10

php /opt/observium/scripts/generate-rancid.php > /usr/local/rancid/var/observium/router.db

exec "$@"
