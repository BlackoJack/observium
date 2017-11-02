# Version: 17.9.0
FROM centos:7
MAINTAINER Raenko Ivan <admin@sysadminsk.ru>

ENV TERM=xterm

ENV MYSQL_DATABASE observium
ENV MYSQL_USER observium
ENV MYSQL_PASSWORD changeme

ENV DOMAIN serv.example.com

ENV ADMIN_USER admin
ENV ADMIN_PASSWORD changeme
ENV ADMIN_EMAIL admin@example.com

ENV SNMP_COMM=public
ENV SNMP_LOC=Rack,\ Room,\ Building,\ City,\ Country\ \[GPSX,Y\]
ENV SNMP_CON=Your\ Name\ \<your@email.address\>


RUN localedef -i ru_RU -f UTF-8 ru_RU.UTF-8 && \
  cp -f /usr/share/zoneinfo/Asia/Novosibirsk /etc/localtime

ENV LANG ru_RU.utf8

ADD scripts/install_system.sh /tmp
RUN /tmp/install_system.sh

ADD scripts/install_observium.sh /tmp
RUN /tmp/install_observium.sh

ADD scripts/install_rancid.sh /tmp
RUN /tmp/install_rancid.sh

ADD scripts/check_owner.sh /
ADD scripts/start.sh /

ADD configs/supervisord.conf /etc/supervisord.conf
ADD configs/supervisor.d/ /etc/supervisord.d/
RUN chmod 600 /etc/supervisord.conf /etc/supervisord.d/*.ini

WORKDIR /opt/observium

VOLUME ["/opt/observium/rrd"]
VOLUME ["/opt/observium/logs"]
VOLUME ["/opt/observium/html"]
VOLUME ["/opt/observium/mibs"]
VOLUME ["/opt/observium/scripts"]
VOLUME ["/home/rancid/.ssh"]
VOLUME ["/usr/local/rancid/var/observium/configs"]
VOLUME ["/usr/local/rancid/var/logs"]

EXPOSE 80
EXPOSE 514/udp
EXPOSE 161/udp

ENTRYPOINT ["/start.sh"]
CMD ["/usr/bin/supervisord"]
