
FROM centos:7

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
 mariadb-server.x86_64 \
 mariadb-devel.x86_64 \
 gcc \
 libstdc++-devel.x86_64 \
 libstdc++-static.x86_64 \
 make \
 unzip \
 libpng-devel.x86_64 \
 tcsh \
 perl \
 git

 # create mysql config file
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

RUN mkdir -p /root/bin/x86_64
#RUN cd /opt && curl -sLo master.zip https://github.com/ucscGenomeBrowser/kent/archive/master.zip && unzip -q master.zip && mv kent-master kent && rm -f master.zip
RUN cd /opt && curl -sLo jksrc.zip http://hgdownload.cse.ucsc.edu/admin/jksrc.zip && unzip -q jksrc.zip && rm -f jksrc.zip
RUN echo 'L+= -lz' >> /opt/kent/src/inc/common.mk
RUN cd /opt/kent/src && make clean && make -j $(nproc) utils

COPY ./update /usr/bin
COPY ./initiate /usr/bin/

CMD ["update"]
