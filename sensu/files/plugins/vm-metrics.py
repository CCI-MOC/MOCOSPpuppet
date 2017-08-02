#!/usr/bin/env python
import sys
import subprocess
import xml.etree.ElementTree as ET
import datetime

command = "virsh list"

remote_output = subprocess.check_output(command.split(), stderr=subprocess.STDOUT)
output = "".join(remote_output.split("\n")[2:])  #remove the top two lines from the output

total_vcpu = 0

for line in output.splitlines():
    instance_name = line.split()[1]  # extract the instance name
    
    #
    command_dumpxml = "virsh dumpxml "+str(instance_name)
    
    dumpxml_output = subprocess.check_output(command_dumpxml.split(), stderr=subprocess.STDOUT)
    root = ET.fromstring(dumpxml_output)
    
    try:
       vcpu = int(root.find('vcpu').text)
       total_vcpu = total_vcpu + vcpu    
    except:
       print "Cant find vcpu for : "+ str(instance_name)
    
       
now = datetime.datetime.now()
now_epoch = int(now.strftime("%s"))

# Convert the time stamp to nano seconds.
now_epoch = now_epoch*1000000000

FORMATTER = "vCPU_metrics,metric={}, Category={},value={},timedelta_sec=60 {} \n"
print FORMATTER.format("vCPU","Usage",total_vcpu,now_epoch)

