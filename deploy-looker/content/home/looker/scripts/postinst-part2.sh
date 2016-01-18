#!/bin/bash -e
# this script is executed on the TARGET MACHINE after the deb is unpacked
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh

# this has to be done "later" since running letsencrypt may 
# try to use package management to get the work complete.

LOOKERHOME=/home/looker

# SSL KEYS ----------------------------------------------------------------------
# set up letsencrypt on this box so we can generate a suitable key
# this relies on some stuff payloded in from /etc/letsencrypt - or does it?

# first fetch the client
cd /home/ubuntu
if [ ! -d letsencrypt ] ; then
    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    # hopefully --help fetches all the dependencies
    # in any event, it uses package management to determine if they're needed
    # so it can't be run while the package manager is still installing looker
    ./letsencrypt-auto certonly --help
else 
    cd letsencrypt
fi
# and cd down into it's directory


# generate (or re-generate) a cert.
# we use the unmodified nginx install and webroot for this
ME=`hostname -f`
SSL=$LOOKERHOME/ssl
mkdir -p $SSL
LE=/etc/letsencrypt/archive/$ME
mkdir -p $LE
PASSWORD=looker
# check to see if this particular cert is already present.  it may be.
if [ ! -f $LE/cert1.pem ] ; then
    ./letsencrypt-auto certonly --webroot -w /usr/share/nginx/html -d $ME --email barry@productops.com --agree-tos
else
    # this should renew if already present ?
    ./letsencrypt-auto run --webroot -w /usr/share/nginx/html -d $ME --email barry@productops.com --agree-tos
fi

# the letsencrypt-auto above needs to have generated keys successfully
# make sure all the files we need are present and accounted for
for F in  $LE/cert1.pem $LE/fullchain1.pem $LE/privkey1.pem 
do
    if [ ! -f $F ] 
    then 
	# generate a self-signed certificate
	openssl req -x509 -newkey rsa:2048 \
	    -keyout $LE/privkey1.pem \
	    -out $LE/cert1.pem \
	    -passout pass:$PASSWORD \
	    -days 3650 \
	    -subj "/C=US/ST=Michigan/L=AnnArbor/O=Ithaka.org/CN=$ME"
#	echo "ERROR: no $F"
#	echo  '      maybe this command failed mysteriously?'
#	echo ./letsencrypt-auto certonly --webroot -w /usr/share/nginx/html -d $ME --email barry@productops.com --agree-tos
#	exit 42
    fi
done

# this should probably not be world-readable, but nginx needs it, as does /etc/init.d/looker
chown -R www-data:www-data /etc/letsencrypt
find /etc/letsencrypt -type d -exec chmod ugo+rx "{}" ";"

# LOOKER.JAR NEEDS A JAVA KEYSTORE --------------------------------------------
# store the magic password in a file
echo $PASSWORD >$SSL/keystorepass
# the $SSL/3pass file just keeps the keytool from hanging on input
( cat $SSL/keystorepass ;cat $SSL/keystorepass ;cat $SSL/keystorepass ) >$SSL/3pass
# now following http://www.looker.com/docs/setup-and-management/on-prem-install/ssl-setup
rm -f $SSL/looker.p12
# if we used letsencrypt, there's no password for the privkey1
if [ -f $LE/fullchain1.pem ] ; then 
openssl pkcs12 -export \
  -in $LE/cert1.pem \
  -CAfile $LE/fillchain1.pem \  
  -inkey $LE/privkey1.pem \
  -out $SSL/looker.p12 \
  -passin pass: -passout file:$SSL/keystorepass
else
# we used a self-signed certificate, but there IS a password, and no chain
openssl pkcs12 -export \
  -in $LE/cert1.pem \
  -inkey $LE/privkey1.pem \
  -out $SSL/looker.p12 \
  -passin pass:$PASSWORD -passout file:$SSL/keystorepass
fi

# this creates a java keystore, which is what looker ultimately needs
rm -f $SSL/looker.jks
cat $SSL/3pass | keytool -importkeystore \
  -srckeystore $SSL/looker.p12 \
  -srcstoretype pkcs12 \
  -destkeystore $SSL/looker.jks \
  -deststoretype JKS \
  -alias 1
# make sure java can read the files
chown -R looker:looker $SSL

# make sure all the files we need are present and accounted for
for F in $SSL/looker.p12 $SSL/looker.jks $SSL/keystorepass
do
    if [ ! -f $F ] ; then 
	echo "ERROR: no $F"
	exit 42 
    fi
done

# NGINX ----------------------------------------------------------------------
# reconfigure nginx using the sample received from Looker 
#     http://www.looker.com/docs/setup-and-management/on-prem-install/sample-nginx-config
ME=`hostname -f`
NGC=/etc/nginx/nginx.conf
if [ ! -f ${NGC}.orig ] ; then 
    cp $NGC ${NGC}.orig
fi
USNH=/usr/share/nginx/html

# change the domain name, and then point to the keys we made earlier 
cat $LOOKERHOME/nginx/looker.conf | sed -e s/looker.domain.com/$ME/ \
    -e "s+/etc/looker/ssl/certs/self-ssl.crt+/etc/letsencrypt/archive/$ME/cert1.pem+" \
    -e "s+/etc/looker/ssl/private/self-ssl.key+/etc/letsencrypt/archive/$ME/privkey1.pem+"  >$NGC
# rewrite the index.html so that it redirects to the correct ssl page
cat $LOOKERHOME/nginx/index.html | sed -e s/looker.domain.com/$ME/g >$USNH/index.html

if ! service nginx restart
then
    echo "ERROR nginx failed to restart"
fi

# start up looker as the right user. ------------------------------------------
WRAPPER=$LOOKERHOME/scripts/looker-wrapper.sh 
echo sudo su - looker $WRAPPER start | at "now +1 minute"
