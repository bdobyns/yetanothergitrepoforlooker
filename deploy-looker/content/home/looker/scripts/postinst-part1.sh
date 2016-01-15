#!/bin/bash -e
# this script is executed on the TARGET MACHINE after the deb is unpacked
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh

# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

LOOKERHOME=/home/looker

# set the permissions and ownership properly ----------------------------------
chown -R looker:looker $LOOKERHOME
chmod -R +x $LOOKERHOME
# this should not be world-readable
chown -R root:root /etc/letsencrypt

# fix up a startup script -----------------------------------------------------

# this does not work right for startup/shutdown
# but it should allow 
#     service looker status
# to work right (for sagoku healthcheck)

WRAPPER=$LOOKERHOME/scripts/looker-wrapper.sh 
cp $WRAPPER  /etc/init.d/looker
chmod +rx /etc/init.d/looker
update-rc.d looker defaults

# SSL KEYS ----------------------------------------------------------------------
# set up letsencrypt on this box so we can generate a suitable key
# this relies on some stuff payloded in from /etc/letsencrypt

# first fetch the client
cd /home/ubuntu
if [ ! -d letsencrypt ] ; then
    git clone https://github.com/letsencrypt/letsencrypt
fi
chown -R ubuntu:ubuntu letsencrypt
# and cd down into it's directory
cd letsencrypt

# generate (or re-generate) a cert.
# we use the unmodified nginx install and webroot for this
ME=`hostname -f`
SSL=$LOOKERHOME/looker/ssl
mkdir -p $SSL
LE=/etc/letsencrypt/archive/$ME
# check to see if this particular cert is already present.  it may be.
if [ ! -f $LE/cert1.pem ] ; then
    ./letsencrypt-auto certonly --webroot -w /usr/share/nginx/html -d $ME --email barry@productops.com --agree-tos
fi

# the letsencrypt-auto above needs to have generated keys successfully
for F in  $LE/cert1.pem $LE/fullchain1.pem $LE/privkey1.pem 
do
    if [ ! -f $F ] ; then exit 42 ; fi
done

# LOOKER.JAR NEEDS A JAVA KEYSTORE --------------------------------------------
echo looker >$SSL/keystorepass
# now following http://www.looker.com/docs/setup-and-management/on-prem-install/ssl-setup
rm $SSL/looker.p12
openssl pkcs12 -export \
  -in $LE/cert1.pem \
  -CAfile $LE/fullchain1.pem \
  -inkey $LE/privkey1.pem \
  -out $SSL/looker.p12 \
  -passin pass: -passout file:$SSL/keystorepass

# the $SSL/3pass file just keeps the keytool from hanging on input
rm $SSL/looker.jks
( cat $SSL/keystorepass ;cat $SSL/keystorepass ;cat $SSL/keystorepass ) >$SSL/3pass
cat $SSL/3pass | keytool -importkeystore \
  -srckeystore $SSL/looker.p12 \
  -srcstoretype pkcs12 \
  -destkeystore $SSL/looker.jks \
  -deststoretype JKS \
  -alias 1
# make sure java can read the files
chown -R looker:looker $SSL

if [ ! -f $SSL/looker.p12 ] || [ ! -f $SSL/looker.jks ] ; then
    exit 42
fi    

# NGINX ----------------------------------------------------------------------
# reconfigure nginx using the sample received from Looker 
#     http://www.looker.com/docs/setup-and-management/on-prem-install/sample-nginx-config
ME=`hostname -f`
NGC=/etc/nginx/nginx.conf
if [ ! -f ${NGC}.orig ] ; then 
    cp $NGC ${NGC}.orig
fi

# change the domain name, and then point to the keys we made earlier 
cat $LOOKERHOME/nginx/looker.conf | sed -e s/looker.domain.com/$ME/ \
    -e "s+/etc/looker/ssl/certs/self-ssl.crt+/etc/letsencrypt/archive/$ME/cert1.pem+" \
    -e "s+/etc/looker/ssl/private/self-ssl.key+/etc/letsencrypt/archive/$ME/privkey1.pem+"  >$NGC

service nginx restart

# start up looker as the right user. ------------------------------------------
echo sudo su - looker $WRAPPER start | at "now +1 minute"

exit 0
