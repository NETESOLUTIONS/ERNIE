/*
  Author:    VJ Davey
  Date:      10/12/2018

  add_server_to_config.groovy
*/

import jenkins.model.*
def name = ""
def username = ""
def hostname = ""
def keyPath = ""

/* Notify user of the configured settings for servername, hostname, username */
println name
println username
println hostname

import jenkins.plugins.publish_over_ssh.BapSshHostConfiguration
def instance = Jenkins.getInstance()
def publish_ssh = instance.getDescriptor("jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin")
def configuration = new BapSshHostConfiguration(
  name:name,
  hostname:hostname,
  username:username,
  overrideKey:true,
  keyPath:keyPath,
  remoteRootDir:'/',
  port:22
)
publish_ssh.addHostConfiguration(configuration)
publish_ssh.save()
