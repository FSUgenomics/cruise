#!/usr/bin/env bash

echo -e 'db.host='${SQL_HOST}'\ndb.user='${SQL_USER}'\ndb.password='${SQL_PASSWORD} > /root/.hg.conf
chmod 600 /root/.hg.conf

rm -f /var/www/cgi-bin/hg.conf && cp -f /opt/kent/src/product/ex.hg.conf /var/www/cgi-bin/hg.conf
sed -i 's/defaultGenome=.*/defaultGenome='"$DEFAULTGENOME"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/wiki\.host=.*/wiki\.host=HTTPHOST/g' /var/www/cgi-bin/hg.conf
sed -i 's/central\.domain=.*/central\.domain=HTTPHOST/g' /var/www/cgi-bin/hg.conf
sed -i 's/central\.host=.*/central\.host='"$SQL_HOST"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/db\.host=.*/db\.host='"$SQL_HOST"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.browserName=.*/login\.browserName='"$BROWSERNAME"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.browserAddr=.*/login\.browserAddr=http:\/\/'"${HOSTNAME}.${DOMAIN}"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.mailSignature=Greenome Browser Staff=.*/login\.mailSignature=Greenome Browser Staff/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$WIKIEMAIL"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/custromTracks\.host=.*/custromTracks\.host=localhost/g' /var/www/cgi-bin/hg.conf
sed -i 's/customTracks\.host=.*/customTracks\.host='"$SQL_HOST"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/customTracks\.user=.*/customTracks\.user=readwrite/g' /var/www/cgi-bin/hg.conf
sed -i 's/customTracks\.password=.*/customTracks\.password=update/g' /var/www/cgi-bin/hg.conf
sed -i 's#customTracks\.tmpdir=.*#customTracks\.tmpdir='/var/www/trash/ct'#g' /var/www/cgi-bin/hg.conf
sed -i 's#browser.documentRoot=.*#browser.documentRoot='/var/www'#g' /var/www/cgi-bin/hg.conf
