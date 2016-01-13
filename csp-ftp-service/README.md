# README for Cats ftp service (CATS-1349)

This readme covers the CATS csp ftp service which is hosted in AWS via Sagoku.

## What is it?

The CATS ftp service is a sagoku debian package deployment of a ftp service which is backed by S3 storage.

## pure-ftpd

We use the `pure-ftpd` debian package for the primary service

* authorization is against IAC using pure-authd and a custom script `/etc/pure-ftpd/scripts/authscript.sh`
* uploads to S3 and notification to BOLT is done using pure-uploadscript and a custom script `/etc/pure-ftpd/scripts/uploadscript.sh`
* both pure-authd and pure-uploadscript are started in the post install script (they are not normally started by `service pure-ftpd start`)
* we use the watchable-sidecar (BOLT-429) to read persistent variables for configuration of bash scripts
* we run an hourly process to clean out files until we meet the "free percentage"

## Persistent Variables

PV Name | default value | meaning 
------- | ------------- | --------
csp_ftp_local_base | `/mnt/csp/ftp/users` | where locally we write files 
csp_ftp_local_free_percentage | `25` | how much free space to try and keep on the volume where files are stored
csp_ftp_s3_bucket | `sequoia-csp-ftp` |
csp_ftp_s3_path |  `$SGK_APP/$SGK_ENVIRONMENT/users` |
csp_ftp_notify_service | `bolt-service` |
csp_ftp_notify_endpoint | `/csp_ftp_notify` |
csp_ftp_required_role | `FTP_Partner` | even if you have valid IAC credentials, you must **also** have this role
csp_ftp_pagerduty_topic | `arn:aws:sns:us-east-1:594813696195:cedar-ingestor-validator` | topic to write a message to when we have terrible news to report
storage-total-1k-blocks | | total amount of storage in 1k blocks 
storage-free-1k-blocks | | total free storage available in 1k blocks 
public_ipv4 | | can be used thru the apps proxy to find the IP address of the instance so that QA scripts can ftp to it 

## Further Research Notes

some helfpul notes on pure-ftpd:

* http://download.pureftpd.org/pub/pure-ftpd/doc/README
* http://download.pureftpd.org/pub/pure-ftpd/doc/README.Authentication-Modules
* http://www.debianhelp.co.uk/pureftp.htm
* http://manpages.ubuntu.com/manpages/hardy/man8/pure-ftpd-wrapper.8.html
* http://linux.die.net/man/8/pure-authd
* http://linux.die.net/man/8/pure-ftpd
* http://linux.die.net/man/8/pure-uploadscript
* http://download.pureftpd.org/pub/pure-ftpd/doc/README.TLS
+ http://manpages.ubuntu.com/manpages/hardy/man8/pure-ftpd-wrapper.8.html
