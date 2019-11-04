#!/bin/bash
#...............................................................
# this bash script would remove the created policy package,
# the gateway object, group objects, host obects, and 
# network objects from the SMS database.
#...............................................................

cd /home/admin

mgmt_cli login -r true > id.txt

mgmt_cli delete package name "dev1_policy_package" -s id.txt

mgmt_cli delete simple-gateway name "dev1-AU-CP-GW" -s id.txt

mgmt_cli delete group --batch dev1_groups_names.csv -s id.txt

mgmt_cli delete host --batch dev1_hosts_names.csv -s id.txt

mgmt_cli delete network --batch dev1_networks_names.csv -s id.txt

mgmt_cli publish -s id.txt
mgmt_cli logout -s id.txt
