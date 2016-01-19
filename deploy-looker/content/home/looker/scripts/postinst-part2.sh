#!/bin/bash -e
# this script is executed on the TARGET MACHINE after the deb is unpacked
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh

# this has to be done "later" since running letsencrypt may 
# try to use package management to get the work complete.

LOOKERHOME=/home/looker
USE_LETSENCRYPT=false       # able to turn off letsencrypt.org stuff
USE_NGINX_PROXY=false       # use nginx for the proxy?  

ME=`hostname -f`
SSL=$LOOKERHOME/ssl
mkdir -p $SSL
LE=/etc/letsencrypt/archive/$ME
mkdir -p $LE
KEYPASS=looker

# MAKE SSL KEYS ---------------------------------------------------------------
try_letsencrypt() {
# LETSENCRYPT.ORG -------------------------------------------------------------
# we try to use letsencrypt.org LIVE RIGHT NOW if there is no file yet
if [ ! -z $USE_LETSENCRYPT ] && [ $USE_LETSENCRYPT == true ] ; then
  # check to see if this particular cert is already present.  it may be.
  if [ ! -f $LE/cert1.pem ] || [ ! -f $LE/privkey1.pem ] ; then
    # set up letsencrypt on this box so we can generate a suitable key
    cd /home/ubuntu
    if [ ! -d letsencrypt ] ; then
        # first fetch the client
	git clone https://github.com/letsencrypt/letsencrypt
	cd letsencrypt
        # hopefully --help fetches all the dependencies
        # in any event, it uses package management to determine if they're needed
        # so it can't be run while the package manager is still installing looker
	./letsencrypt-auto certonly --help
    else 
        # and cd down into it's directory
	cd letsencrypt
    fi
    # we ask for a SAN certificate for basically any $SGK_APP hosts in this env
    SAN=/tmp/$$.hosts.txt
    echo >$SAN
    for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39
    do 
	# make sure we don't include $ME twice, dunno if this will muck up letsencrypt, but no need to find out
	H=${SGK_APP}${i}.${SGK_ENVIRONMENT}.$SGK_BASE_DOMAIN 
	if [ $H != $ME ] ; then
	    echo -d $H >>$SAN
	fi
    done
    # generate (or re-generate) a cert.
    # we use the unmodified nginx install and webroot for this
    ./letsencrypt-auto certonly --webroot -w /usr/share/nginx/html d $ME `cat $SAN` --email barry@productops.com --agree-tos
  else
    echo "did not run letsencrypt: already have keys $LE/cert1.pem and $LE/privkey1.pem"
# else
    # I think this is how you renew, but not completely sure.
    # ./letsencrypt-auto run --webroot -w /usr/share/nginx/html -d $ME --email barry@productops.com --agree-tos
  fi
else
    echo "did not run letsencrypt because USE_LETSENCRYPT == '$USE_LETSENCRYPT' "
fi
}

try_self_signed() {
# SELF-SIGNED -----------------------------------------------------------------
# okay, letsencrypt.org failed, so try self-signing
if [ ! -f $LE/cert1.pem ] || [ ! -f $LE/privkey1.pem ] ; then
        # delete the trust chain, if self-signing
        rm -rf $LE/fullchain1.pem
	# generate a self-signed certificate
	openssl req -x509 -newkey rsa:2048 \
	    -keyout $LE/privkey1.pem \
	    -out $LE/cert1.pem \
	    -passout pass:$KEYPASS \
	    -days 3650 \
	    -subj "/C=US/ST=Michigan/L=AnnArbor/O=Ithaka.org/CN=$ME"
else
    echo "did not self-sign: already have keys $LE/cert1.pem and $LE/privkey1.pem"
fi
}

has_keys(){
# DID WE GET KEYS -------------------------------------------------------------
# some of this keygen ought to have succeeded.  ron says trust, but verify.
# make sure all the files we need are present and accounted for
for F in  $LE/cert1.pem $LE/privkey1.pem # $LE/fullchain1.pem
do
    if [ ! -f $F ] 
    then 
	echo "ERROR: no $F"
	exit 42
    fi
done
}

make_java_keystore(){
# this should probably not be world-readable, but nginx needs it, as does /etc/init.d/looker
chown -R www-data:www-data /etc/letsencrypt
find /etc/letsencrypt -type d -exec chmod ugo+rx "{}" ";"


# LOOKER.JAR NEEDS A JAVA KEYSTORE --------------------------------------------
# store the magic password in a file
# we later refer to keystorepass in a command line arg to looker in lookerstart.cfg
echo $KEYPASS >$SSL/keystorepass
# the $SSL/3pass file just keeps the keytool from hanging on input
(echo $KEYPASS ; echo $KEYPASS ; echo $KEYPASS ) >$SSL/3pass
# now following http://www.looker.com/docs/setup-and-management/on-prem-install/ssl-setup
rm -f $SSL/looker.p12

# read privkey1.pem and cert1.pem to make looker.p12
if [ -f $LE/fullchain1.pem ] ; then 
# if we used letsencrypt, there's no password for the privkey1, but we do have a signing chain
openssl pkcs12 -export \
  -in $LE/cert1.pem \
  -CAfile $LE/fullchain1.pem \
  -inkey $LE/privkey1.pem \
  -out $SSL/looker.p12 \
  -passin pass: -passout file:$SSL/keystorepass
else
# we used a self-signed certificate, there IS a password, and no signing chain
openssl pkcs12 -export \
  -in $LE/cert1.pem \
  -inkey $LE/privkey1.pem \
  -out $SSL/looker.p12 \
  -passin pass:$KEYPASS -passout file:$SSL/keystorepass
fi

# read looker.p12 to make looker.jks
# this creates a java keystore, which is what looker ultimately needs
# keytool is something like /usr/lib/jvm/jdk1.7.0_55/bin/keytool
rm -f $SSL/looker.jks
cat $SSL/3pass | keytool -importkeystore \
  -srckeystore $SSL/looker.p12 \
  -srcstoretype pkcs12 \
  -destkeystore $SSL/looker.jks \
  -deststoretype JKS \
  -alias 1
# make sure java can read the files
chown -R looker:looker $SSL
}

has_jks() {
# DID JAVA KEYSTORE WORK ------------------------------------------------------
# make sure all the files looker needs are present and accounted for
for F in $SSL/looker.p12 $SSL/looker.jks $SSL/keystorepass
do
    if [ ! -f $F ] ; then 
	echo "ERROR: no $F"
	exit 42 
    fi
done
echo " "
}

start_nginx() {
# NGINX OR IPTABLES -----------------------------------------------------------
if [ ! -z $USE_NGINX_PROXY ] && [ $USE_NGINX_PROXY == true ] && [ -f $LE/fullchain1.pem ] ; then
    # NGINX -------------------------------------------------------------------
    # we can only use NGINX if we have a proper cert from a CA, for some unknown reason
    #
    # reconfigure nginx using the sample received from Looker 
    #     http://www.looker.com/docs/setup-and-management/on-prem-install/sample-nginx-config
    NGC=/etc/nginx/nginx.conf
    if [ ! -f ${NGC}.orig ] ; then 
	cp $NGC ${NGC}.orig
    fi
    # this is where the default index.html is kept
    USNH=/usr/share/nginx/html

    # rewrite the config to change the domain name, and then point to the keys we made earlier 
    cat $LOOKERHOME/nginx/looker.conf | sed -e s/looker.domain.com/$ME/ \
	-e "s+/etc/looker/ssl/certs/self-ssl.crt+/etc/letsencrypt/archive/$ME/cert1.pem+" \
	-e "s+/etc/looker/ssl/private/self-ssl.key+/etc/letsencrypt/archive/$ME/privkey1.pem+"  >$NGC
    # rewrite the payloaded index.html so that it redirects to the correct ssl page
    cat $LOOKERHOME/nginx/index.html | sed -e s/looker.domain.com/$ME/g >$USNH/index.html
    
    # decide what to do based on whether it's up already
    if service nginx status >/dev/null ; then
	# nginx already running
	if ! service nginx restart
	then
	    echo "ERROR nginx failed to restart"
	fi
    else
	# nginx not already running
	if ! service nginx start
	then
	    echo "ERROR nginx failed to start"
	fi
    fi
else
    if [ ! -f $LE/fullchain1.pem ] ; then
	echo "cannot start nginx because no $LE/fullchain1.pem"
    else
	echo "cannot start nginx because USE_NGINX_PROXY == $USE_NGINX_PROXY"
    fi
fi
}

start_iptables() {
if [ ! -z $USE_NGINX_PROXY ] && [ $USE_NGINX_PROXY == true ] && [ -f $LE/fullchain1.pem ] ; then
    echo "should use nginx, not iptables"
else
    # IPTABLES --------------------------------------------------------------------
    # iptables always works, even when nginx does not

    # turn off nginx if it's on
    if service nginx status >/dev/null ; then
	service nginx stop
    fi

    # set up to use iptables
    LKFWD=/etc/network/if-up.d/looker-https-forward
    # create the LKFWD if it doesn't exist
    if [ ! -f $LKFWD ] ; then
        cat >$LKFWD <<EOF
#!/bin/sh
# Forward HTTPS traffic to the Looker app
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 9999
EOF
        chmod 755 $LKFWD
    fi
    # start it if there's no rule yet that corresponds
    if ! iptables -t nat -L | grep ^REDIRECT | grep dpt:https | grep 9999 >/dev/null
    then
	$LKFWD
    fi
fi
}


start_looker() {
# LOOKER.JAR ------------------------------------------------------------------
# pre-configure a user, and preload the license key
#    see https://discourse.looker.com/t/auto-provisioning-a-looker-instance/1698
YAMLF=$LOOKERHOME/looker/provision.yml
TEMPL=$LOOKERHOME/looker/provision.template
cat $TEMPL | sed -e s/looker.domain.com/$ME/ >$YAMLF
chown looker:looker $YAMLF

# we also copied the wrapper into /etc/init.d/looker in part1
WRAPPER=$LOOKERHOME/scripts/looker-wrapper.sh 
# looker.jar has to run as user looker
echo sudo su - looker $WRAPPER start | at "now +1 minute"
}


# NORMALLY RUNS WITH NO ARGS --------------------------------------------------
# but in the edge case where we have args, just do one function
case $1 in 
    letsencrypt)
	USE_LETSENCRYPT=true
	try_letsencrypt
	has_keys  # did it work?
	;;
    selfsigned)
	try_self_signed
	has_keys  # did it work?
	;;
    keystore|javakeystore|java_keystore)
	has_keys  # java keystore uses the ssl keys
	make_java_keystore
	has_jks   # did it work?
	;;
    nginx)
	has_keys  # nginx needs the ssl keys
	start_nginx
	;;
    iptables)
	start_iptables
	;;
    looker)
	has_jks   # looker needs the java keys
	start_looker
	;;
    -h|--help|help)
	echo "usage:   $0  [ letsencrypt | selfsigned | keystore | nginx | iptables | looker ]"
	echo "         $0  letsencrypt   - try to get the keys from letsencrypt.org"
	echo "         $0  selfsigned    - make self-signed keys locally"
	echo "         $0  keystore      _ make the java keystore from the pem"
	echo "         $0  nginx         - edit nginx configs, start nginx"
	echo "         $0  iptables      - stop nginx, start iptables"
	echo "         $0  looker        - edit looker provision.yml, start looker"
	exit 42
	;;
    *)
	try_letsencrypt
	try_self_signed
	has_keys
	make_java_keystore
	has_jks
	start_nginx
	start_iptables
	start_looker
	;;
esac

