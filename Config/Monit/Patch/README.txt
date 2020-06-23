Patch for the Postgres monitoring issue:
https://bitbucket.org/tildeslash/monit/issues/715/monit-use-of-pgsql-protocol-on-sockets

Massimo Sala <massimo.sala.71@gmail.com>:

it is not so easy to compile Monit.

I had to grow my know-how, Tildeslash is not so useful.

I feel it is a shame to loose my work, so I try to give you a little support.

I send you a zip file with
* the monit 5.26.1 binary (read later)
* the script to compile monit
* the 5.26.1 sources

Usage
* download Monit 5.26.0 sources: https://mmonit.com/monit/dist/monit-5.26.0.tar.gz

* cd /tmp and expand the file, you have /tmp/monit-5.26.0
* cd /tmp and expand my zip archive , you have /tmp/monit-5.26.1

* cd /tmp/monit-5.26.0

Mark the script as executable:
* chmod u+rx /tmp/monit-5.26.1/mk_monit.sh

Edit the script to change the installation folder (DESTDIR=/opt/monit)
Run the script:
* /tmp/monit-5.26.1/mk_monit.sh /tmp/monit-5.26.1/monit.zip

Note: I wrote now these steps, untested; I use my own "dirty in-house CVS" to handle the files and the build steps.
Take these instructions as hints to build your knowledge.
