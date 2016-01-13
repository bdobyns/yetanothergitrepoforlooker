#!/bin/bash
set -x
for i in barrydobyns bolt_admin
do
	userdel $i
	groupdel $i
	rm -rf /home/$i /mnt/csp/ftp/users/$i
done

for eid in 1562f13b-4828-4fae-b056-bc98f9cf600e 6afa0c79-12f7-3ba6-90d2-c6c511048139 ; do
    for pref in CspFtpGid CspFtpUid ;do
        curl --silent "http://iac-service.apps.test.cirrostratus.org:80/account/preference/"$pref"?acctId="$eid"&acctIdType=externalId" --request DELETE
    done
done
       