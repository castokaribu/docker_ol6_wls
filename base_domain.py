#!/usr/bin/python
# Author : Tim Hall
# Save Script as : create_domain.py

import time
import getopt
import sys
import re

# Get location of the properties file.
properties = ''
try:
   opts, args = getopt.getopt(sys.argv[1:],"p:h::",["properies="])
except getopt.GetoptError:
   print 'create_domain.py -p <path-to-properties-file>'
   sys.exit(2)
for opt, arg in opts:
   if opt == '-h':
      print 'create_domain.py -p <path-to-properties-file>'
      sys.exit()
   elif opt in ("-p", "--properties"):
      properties = arg
print 'properties=', properties

# Load the properties from the properties file.
from java.io import FileInputStream
 
propInputStream = FileInputStream(properties)
configProps = Properties()
configProps.load(propInputStream)

# Set all variables from values in properties file.
mwhome=configProps.get("path.middleware.home")
wlsPath=mwhome +"/"+ configProps.get("path.wls")
domainsPath=mwhome +"/"+ configProps.get("path.domains")
domainName=configProps.get("domain.name")
username=configProps.get("domain.username")
password=configProps.get("domain.password")
adminPort=configProps.get("domain.admin.port")
adminAddress=configProps.get("domain.admin.address")
adminPortSSL=configProps.get("domain.admin.port.ssl")
serverMode=configProps.get("domain.serverMode")

# Display the variable values.
print 'wlsPath=', wlsPath
print 'domainsPath=', domainsPath
print 'domainName=', domainName
print 'username=', username
print 'password=', password
print 'adminPort=', adminPort
print 'adminAddress=', adminAddress
print 'adminPortSSL=', adminPortSSL
print 'serverMode=', serverMode

# Load the template. Versions < 12.2
readTemplate(wlsPath + '/common/templates/domains/wls.jar')

# Load the template. Versions >= 12.2
#selectTemplate('Base WebLogic Server Domain')
#loadTemplates()

# AdminServer settings.
cd('/Security/base_domain/User/' + username)
cmo.setPassword(password)
cd('/Server/AdminServer')
cmo.setName('AdminServer')
cmo.setListenPort(int(adminPort))
cmo.setListenAddress(adminAddress)

# Enable SSL. Attach the keystore later.
create('AdminServer','SSL')
cd('SSL/AdminServer')
set('Enabled', 'True')
set('ListenPort', int(adminPortSSL))

# If the domain already exists, overwrite the domain
setOption('OverwriteDomain', 'true')

#prod or dev
setOption('ServerStartMode',serverMode)

writeDomain(domainsPath + '/' + domainName)
closeTemplate()
exit()