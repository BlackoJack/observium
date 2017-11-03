#!/bin/bash
#
#
#

fkey='/home/rancid/.ssh/id_rsa'

fuser=$(ls -l $fkey | awk '{ print $3 }')
fgroup=$(ls -l $fkey | awk '{ print $4 }')
fchmod=$(stat -c %a $fkey)

if [ "$fuser" != "rancid" -o "$fgroup" != "rancid" ]
then
  chown rancid. $fkey
fi

if [ "$fchmod" -ne 600 ]
then
  chmod 600 $fkey
fi

/usr/bin/php /opt/observium/scripts/generate-rancid.php > /usr/local/rancid/var/observium/router.db
su - rancid /usr/local/rancid/bin/rancid-run >> /dev/null 2>&1
