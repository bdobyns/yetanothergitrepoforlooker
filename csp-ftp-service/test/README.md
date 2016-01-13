# README for Debian/Sagoku Test Framework

## What is This?

This is a test framework that allows you to run a `package.sh` used by sagoku to build a debian without doing a complete deployment.   

## Unit Test Framework

Uses the [shUnit2 test framework](https://code.google.com/p/shunit2/). The unit test framework
should run on an Ubuntu Linux system which should closely match the sagoku environment.

The test framework will test the setup and installation of the `build/package.sh` shell script.

All of the scripts are in the `test` directory. The scripts are explained:

* `common.sh`: shared variables for all scripts
* `setup.sh`: sets up the Ubuntu environment to simulate a build server and sagoku deployment
* `test.sh`: runs the unit tests to ensure that the services isntalled by the .deb file are correct
* `teardown.sh`: cleaned up the test data and services

The `teardown.sh` script should always be called before checking in code. We should not check in the
shunit2-x.x.x directory or the symbolic link to shunit

## Development Process

1. Make changes to `build/package.sh` - which is the product
2. Add any packages or test preconditions to `setup.sh`
3. Add new test cases to `test.sh`
4. Use sudo to execute `setup.sh`, run `test.sh`
5. Use sudo to execute `teardown.sh` to cleanup environment
6. Commit and checkin code

some helfpul notes on pure-ftpd:

* http://download.pureftpd.org/pub/pure-ftpd/doc/README
* http://download.pureftpd.org/pub/pure-ftpd/doc/README.Authentication-Modules
* http://www.debianhelp.co.uk/pureftp.htm
* http://manpages.ubuntu.com/manpages/hardy/man8/pure-ftpd-wrapper.8.html
* http://linux.die.net/man/8/pure-authd
* http://linux.die.net/man/8/pure-ftpd
* http://linux.die.net/man/8/pure-uploadscript
* http://download.pureftpd.org/pub/pure-ftpd/doc/README.TLS
