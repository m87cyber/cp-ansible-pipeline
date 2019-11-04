#!/bin/bash
#...............................................................
# this bash script would perform the security policy
# provisioning using 'mgmt_cli' commands which would 
# directly engage the automation server on the SMS.
#...............................................................

cd /home/admin

######################
# Login to a session #
######################
mgmt_cli login -r true > id.txt


###############
# Add objects #
###############
mgmt_cli add host --batch dev1_hosts.csv -s id.txt
mgmt_cli set host name "dev1_HOST_172.16.1.101" nat-settings.auto-rule true nat-settings.ip-address "192.168.202.110" nat-settings.method static -s id.txt
mgmt_cli add network --batch dev1_networks.csv -s id.txt
mgmt_cli add group --batch dev1_groups_names.csv -s id.txt
mgmt_cli set group --batch dev1_groups.csv -s id.txt


######################
# Add policy package #
######################
mgmt_cli add package name "dev1_policy_package" comments "Created by ansible for dev1_chkp" color "green" threat-prevention "true" access "true" -s id.txt


####################
# Add access rules #
####################
mgmt_cli add access-section layer "dev1_policy_package Network" position "top" name "(1) management rules" -s id.txt

mgmt_cli add access-rule layer "dev1_policy_package Network" name "cp-gw management access" position.top "(1) management rules" source "dev1_HOST_10.1.1.201" destination "dev1-AU-CP-GW" service.1 "ssh" service.2 "https" action "accept" track "Log" -s id.txt

mgmt_cli add access-rule layer "dev1_policy_package Network" name "stealth rule" position.above "Cleanup rule" source "any" destination "dev1-AU-CP-GW" service "any" action "drop" track "Log" -s id.txt

mgmt_cli add access-section layer "dev1_policy_package Network" name "(2) internal-internal access rules" position.above "Cleanup rule" -s id.txt

mgmt_cli add access-rule layer "dev1_policy_package Network" name "access to DMZ1" position.top "(2) internal-internal access rules" source.1 "dev1_NET_10.1.1.0" source.2 "dev1_NET_10.2.2.0" destination "dev1_NET_172.16.1.0" service "any" action "accept" track "Log" -s id.txt

mgmt_cli add access-rule layer "dev1_policy_package Network" name "external access to zabbix" position.above "Cleanup rule" source "dev1_NET_192.168.202.0" destination "dev1_HOST_172.16.1.101" service "http" action "accept" track "Log" -s id.txt

mgmt_cli add access-rule layer "dev1_policy_package Network" name "zabbix access to internal nets" position.above "Cleanup rule" source "dev1_HOST_172.16.1.101" destination.1 "dev1_NET_10.1.1.0" destination.2 "dev1_NET_10.2.2.0" service "any" action "accept" track "Log" -s id.txt

mgmt_cli add access-rule layer "dev1_policy_package Network" name "block access to internal nets" position.above "Cleanup rule" source "any" destination "dev1_internal_nets" service "any" action "drop" track "Log" -s id.txt

mgmt_cli add access-section layer "dev1_policy_package Network" name "(3) internal-external access rules" position.above "Cleanup rule" -s id.txt  

mgmt_cli add access-rule layer "dev1_policy_package Network" name "dns queries" position.top "(3) internal-external access rules" source "dev1_internal_nets" destination "dev1_HOST_192.168.202.214" service "dns" action "accept" track "Log" -s id.txt

mgmt_cli add access-rule layer "dev1_policy_package Network" name "Internet access" position.above "Cleanup rule" source "dev1_internal_nets" destination "any" service.1 "http" service.2 "https" action "accept" track "Log" -s id.txt

mgmt_cli add access-section layer "dev1_policy_package Network" name "default drop" position.above "Cleanup rule" -s id.txt


#################
# Add NAT rules #
#################
mgmt_cli add nat-section package "dev1_policy_package" name "dev1_chkp manual NAT rules" position "top" -s id.txt

mgmt_cli add nat-rule package "dev1_policy_package" comments "Internal subnets NAT" position.top "dev1_chkp manual NAT rules" original-source "dev1_internal_nets" original-destination "dev1_internal_nets" -s id.txt

mgmt_cli add nat-rule package "dev1_policy_package" comments "Internal subnets NAT" position.bottom "dev1_chkp manual NAT rules" original-source "dev1_internal_nets" translated-source "dev1-CP-GW-Hide" method "hide" -s id.txt


###################
# Publish changes #
###################
mgmt_cli publish -s id.txt


##################
# Install Policy #
##################
mgmt_cli install-policy policy-package "dev1_policy_package" access "true" threat-prevention "false" targets "dev1-AU-CP-GW" -s id.txt

mgmt_cli install-policy policy-package "dev1_policy_package" access "false" threat-prevention "true" targets "dev1-AU-CP-GW" -s id.txt


#########################
# Logout of the session #
#########################
mgmt_cli logout -s id.txt
