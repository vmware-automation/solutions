#!/bin/bash
USER=root
PASSWD="vmware"
VCENTER=172.16.227.130
IPS=172.16.227.141,172.16.227.186
RULETYPE=antiaffinity
RULENAME="My AntiAffinity Rule"
java -cp bin/vFabricApplicationDirectorExtensions.jar:lib/vijava520110926.jar:lib/dom4j-1.6.1.jar com.springsource.pso.vfabricappd.extensions.Main -r "$RULETYPE" -u "$USER" -v "$VCENTER" -p "$PASSWD" -ips "$IPS" -n "$RULENAME"
