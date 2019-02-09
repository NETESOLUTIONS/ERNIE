#!/bin/bash
#** Usage notes are incorporated into online help (-h). The format mimics a manual page.
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  prep_and_install_solr.sh -- Prep server and install Solr

SYNOPSIS
  Usage:
  prep_and_install_solr.sh -h: display this help

DESCRIPTION
  This script will install solr along with necessary prerequisites via yum.

NOTE
  Success of this job is dependent upon pre-established Azure privileges and a saved connection via cli
  Run this job *AFTER* all necessary discs have been mounted. You may ideally want to
    establish the write directory for Solr in a larger storage location than the default
HEREDOC
  exit 1
fi

target_disk=$1 #TODO switch to opt use

# Install Java
yum -y install java-1.8.0-openjdk
yum -y install java-1.8.0-openjdk-devel

# Download and install anaconda.
wget "https://repo.continuum.io/archive/Anaconda3-4.3.0-Linux-x86_64.sh"
bash Anaconda3-4.3.0-Linux-x86_64.sh -b -p /anaconda

# Install additional libraries
/anaconda/bin/conda install -y simplejson

#Use WGET to pull the desired version of Solr from the source
solr_version="7.1.0"
wget "http://archive.apache.org/dist/lucene/solr/${solr_version}/solr-${solr_version}.tgz"
tar zxf solr-${solr_version}.tgz

#Install Solr as a service. Add desired JAR files for easier interaction with main server
bash solr-${solr_version}/bin/install_solr_service.sh solr-${solr_version}.tgz -n
wget -P /opt/solr/server/lib/ "https://jdbc.postgresql.org/download/postgresql-42.2.5.jar"

#Offload the home+data directory to a seperate disk and point with symlink
mkdir ${target_disk}/solr_home
chown solr:solr ${target_disk}/solr_home
mv /var/solr/* ${target_disk}/solr_home
rm -rf /var/solr
ln -s ${target_disk}/solr_home /var/solr
chown solr:solr /var/solr
service solr start
