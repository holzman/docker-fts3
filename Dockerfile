FROM slateci/fts3
RUN yum -y install mariadb
EXPOSE 8446 8449

# Openshift/OKD run by default as a non-privileged user (with group==root).

# Grant group write access
RUN chmod -R 775 /etc/grid-security /etc/httpd /run/httpd /var/log/httpd /var/lib/fts3 /var/log/fts3 /var/log/fts3rest /var/lib/fts3 /usr/share/fts3web
RUN chmod 775 /run /etc/fts3
RUN chmod g=u /etc/passwd

# Grant group read access
RUN chmod 664 /etc/fts3/*
RUN chmod 660 /etc/pki/tls/certs/localhost.crt /etc/pki/tls/private/localhost.key

# Change group from apache to root
RUN chgrp -R root /run/httpd /etc/fts3web

# Don't listen on privileged ports
RUN sed -i 's/Listen 80/#Listen 80/' /etc/httpd/conf/httpd.conf
RUN sed -i 's/Listen 443/#Listen 443/' /etc/httpd/conf.d/ssl.conf

# crond has to run as root :(
RUN chmod u+s /usr/sbin/crond

COPY docker-entrypoint.sh /tmp/docker-entrypoint.sh
ENTRYPOINT sh /tmp/docker-entrypoint.sh

# supervisord writes logs to cwd
WORKDIR /var/log/supervisor
