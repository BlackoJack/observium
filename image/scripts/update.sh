#!/bin/bash
#
#
#

cd /opt && wget http://www.observium.org/observium-community-latest.tar.gz && tar zxvf observium-community-latest.tar.gz && rm -f observium-community-latest.tar.gz
/opt/observium/discovery.php -u
