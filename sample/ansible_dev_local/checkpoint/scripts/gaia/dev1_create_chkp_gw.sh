#!/bin/bash
#...............................................................
# this bash script would create the gateway object on the SMS
# using 'mgmt_cli' commands which would locally engage the 
# automation server on the SMS.
#...............................................................

cd /home/admin

mgmt_cli login -r true > id.txt

#---------------------------------------------------------------
# Modify the following line to change the definition of 
# the gateway object.
#
mgmt_cli add simple-gateway name "dev1-AU-CP-GW" ipv4-address "10.1.1.1" color "blue" version "R80.30" firewall true vpn true ips true anti-bot true anti-virus true tags "dev1" one-time-password "vpn123" interfaces.1.name "eth0" interfaces.1.ipv4-address "10.1.1.1" interfaces.1.ipv4-network-mask "255.255.255.0" interfaces.1.topology "internal" interfaces.1.anti-spoofing true interfaces.1.topology-settings.ip-address-behind-this-interface "network defined by the interface ip and net mask" interfaces.2.name "eth1" interfaces.2.ipv4-address "172.16.1.1" interfaces.2.ipv4-network-mask "255.255.255.0" interfaces.2.topology "internal" interfaces.2.anti-spoofing true interfaces.2.topology-settings.ip-address-behind-this-interface "network defined by the interface ip and net mask" interfaces.3.name "eth2" interfaces.3.ipv4-address "10.2.2.1" interfaces.3.ipv4-network-mask "255.255.255.0" interfaces.3.topology "internal" interfaces.3.anti-spoofing true interfaces.3.topology-settings.ip-address-behind-this-interface "network defined by the interface ip and net mask" interfaces.4.name "eth3" interfaces.4.ipv4-address "192.168.202.111" interfaces.4.ipv4-network-mask "255.255.255.0" interfaces.4.topology "external" interfaces.4.anti-spoofing true -s id.txt

mgmt_cli publish -s id.txt
mgmt_cli logout -s id.txt
