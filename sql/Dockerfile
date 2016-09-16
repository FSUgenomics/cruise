
FROM vera/kent:latest

MAINTAINER "Daniel Vera" vera@genomics.fsu.edu
VOLUME /var/lib/mysql
VOLUME /gbdb
EXPOSE 3306

ENV CGI_BIN=/var/www/cgi-bin
ENV SAMTABIXDIR=/opt/samtabix/
ENV USE_SSL=1
ENV USE_SAMTABIX=1
ENV MACHTYPE=x86_64
ENV PATH=/root/bin/x86_64:/opt/samtabix/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN yum update -y && yum install -y \
 mariadb-server.x86_64

 RUN echo -e '[mysqld]\n'\
 'user                   =mysql\n'\
 'datadir                =/var/lib/mysql\n'\
 'symbolic-links         =1\n'\
 'loose-local-infile     =1\n'\
 'default-storage-engine =MYISAM\n'\
 '[mysqld_safe]\n'\
 'log-error              =/var/log/mariadb/mariadb.log\n'\
 'pid-file               =/var/run/mariadb/mariadb.pid\n'\
 'socket                 =/var/lib/mysql/mysql.sock\n'\
  > /etc/my.cnf

COPY ./update /usr/bin
COPY ./initiate /usr/bin/

CMD ["update"]
