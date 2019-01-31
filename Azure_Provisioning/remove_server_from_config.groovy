/*
  Author:    VJ Davey
  Date:      10/24/2018

  remove_sever_from_config.groovy
*/

import jenkins.model.*
def name = ""
println name

def instance = Jenkins.getInstance()
def publish_ssh = instance.getDescriptor("jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin")
publish_ssh.removeHostConfiguration(name)
publish_ssh.save()
