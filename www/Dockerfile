
FROM vera/kent:latest

MAINTAINER "Daniel Vera" vera@genomics.fsu.edu
VOLUME /gbdb
EXPOSE 80


ENV CGI_BIN=/var/www/cgi-bin
ENV SAMTABIXDIR=/opt/samtabix/
ENV USE_SSL=1
ENV USE_SAMTABIX=1
ENV MACHTYPE=x86_64
ENV PATH=/root/bin/x86_64:/opt/samtabix/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN yum update -y && yum install -y \
 httpd \
 mariadb.x86_64

 # download latest browser site from UCSC
 RUN rsync -avz \
--exclude 'hgCgiData' \
--exclude 'hgGeneData' \
--exclude 'hgNearData' \
--exclude 'hgcData' \
 rsync://hgdownload.cse.ucsc.edu/cgi-bin/ /var/www/cgi-bin

 RUN rsync -avz \
 --exclude 'ENCODE' \
 --exclude 'RNA-img' \
 --exclude 'Neandertal' \
 --exclude 'mammalPsg' \
 --exclude 'phylo' \
 --exclude 'ashg2009' \
 --exclude 'ashg2014' \
 rsync://hgdownload.cse.ucsc.edu/htdocs/ /var/www/

 # make symlinks to address bugs in file references
 RUN ln -s /var/www /var/www/html && \
 ln -s /var/www /var/www/htdocs && \
 mkdir /usr/local/apache && \
 ln -s /var/www /usr/local/apache/htdocs && \
 ln -s /var/www/cgi-bin /usr/lib/cgi-bin && \
 ln -s /var/www/cgi-bin /var/www/cgi-bin- && \
 ln -s /var/www/cgi-bin /var/www/cgi-bin-root && \
 ln -s /gbdb /var/www/gbdb

# fix permissions for website data
RUN rm -fr /var/www/trash && \
 mkdir -p /var/www/trash && \
 chmod 777 /var/www/trash && \
 chown -R apache:apache /var/www && \
 chown -R 755 /var/www

# make software directory
# RUN mkdir -p /opt/bin/x86_64 && ln -s /opt/bin ~/bin

# grab and compile samtabix
# RUN git clone http://genome-source.cse.ucsc.edu/samtabix.git /opt/samtabix && cd /opt/samtabix && make

# grab and compile kent source
#RUN cd /opt && curl -sLo master.zip https://github.com/ucscGenomeBrowser/kent/archive/master.zip && unzip -q master.zip && mv kent-master kent && rm -f master.zip
#RUN cd /opt && curl -sLo jksrc.zip http://hgdownload.cse.ucsc.edu/admin/jksrc.zip && unzip -q jksrc.zip && rm -f jksrc.zip

# fix some problems with source code
#RUN sed -i 's/hgBeacon//g;s/hgMirror//g' /opt/kent/src/hg/makefile
#RUN echo 'L+= -lz' >> /opt/kent/src/inc/common.mk
RUN cd /opt/kent/src && make -j $(nproc) blatSuite
RUN cd /opt/kent/src && make -j $(nproc) cgi

 # copy webBlat to cgi-bin
RUN rm -f /var/www/cgi-bin/webBlat && \
 cp -f /opt/kent/src/webBlat/webBlat /var/www/cgi-bin/ && \
 rm -f /var/www/cgi-bin/webBlat.cfg && \
 cp -f /opt/kent/src/webBlat/webBlat.cfg /var/www/cgi-bin/

#RUN pkill httpd || :
RUN sed -i 's#\/var\/www\/html#\/var\/www#g' /etc/httpd/conf/httpd.conf
RUN echo -e 'XBitHack on\n<Directory /var/www/>\nOptions +Includes\n</Directory>' >> /etc/httpd/conf/httpd.conf

COPY ./update /usr/bin/

CMD ["update"]
