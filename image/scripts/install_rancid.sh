#!/bin/bash
#
#
#

yum -y -q install subversion gcc expect sendmail automake openssh-clients

groupadd rancid
useradd -g rancid -c "Networking Backups" -d /home/rancid rancid
usermod -a -G rancid apache
mkdir -p /home/rancid/tar && cd /home/rancid/tar/ && wget ftp://ftp.shrubbery.net/pub/rancid/rancid-3.7.tar.gz && tar -zxvf rancid-3.7.tar.gz
cd /home/rancid/tar/rancid-3.7 && ./configure --prefix=/usr/local/rancid && make install
cat <<EOF > /home/rancid/.cloginrc
add user * rancid
add password * password
add identity * /home/rancid/.ssh/id_rsa
add method * ssh
add noenable * {1}
EOF
chmod 0640 /home/rancid/.cloginrc
chown -hR rancid. /home/rancid
chown -R rancid:rancid /usr/local/rancid/
chmod 775 /usr/local/rancid/

echo "LIST_OF_GROUPS=\"observium\"" >> /usr/local/rancid/etc/rancid.conf
sed -i "s|CVSROOT=\$BASEDIR/CVS; export CVSROOT|CVSROOT=\$BASEDIR/SVN; export CVSROOT|" /usr/local/rancid/etc/rancid.conf
sed -i "s|RCSSYS=cvs; export RCSSYS|RCSSYS=svn; export RCSSYS|" /usr/local/rancid/etc/rancid.conf
su - rancid /usr/local/rancid/bin/rancid-cvs

cp /home/rancid/.cloginrc /root/
chown root /home/rancid/.cloginrc /root/

echo "\$config['rancid_configs'][]              = \"/usr/local/rancid/var/observium/configs/\";" >> /opt/observium/config.php
echo "\$config['rancid_ignorecomments']        = 0;" >> /opt/observium/config.php
echo "\$config['rancid_version'] = '3';" >> /opt/observium/config.php

echo "0 4 * * * /usr/bin/php /opt/observium/scripts/generate-rancid.php > /usr/local/rancid//var/observium/router.db" >> /etc/crontab
echo "0 5 * * * rancid /usr/local/rancid/bin/rancid-run" >> /etc/crontab
echo "50 23 * * * rancid /usr/bin/find /usr/local/rancid/var/logs -type f -mtime   +2 -exec rm {} \;" >> /etc/crontab
echo "" >> /etc/crontab

