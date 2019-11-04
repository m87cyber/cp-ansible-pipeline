#!/bin/bash
#
#--------------------------------------------------------------------
#
#         NAME:   2_cpap_sample_builder.sh
#
#        USAGE:   bash 2_cpap_sample_builder.sh [-i] [-v] 
#
#  DESCRIPTION:   Create sample playbooks for the deployment of a 
#                 Check Point R8.30 Security Gateway as well as its 
#                 decommissioning.
#
# REQUIREMENTS:   Check Point R80.x Security Management Server 
#                 VMWare vCenter 
#                 A Security GW Gaia R80.x VM template
#                 Sample General, VMWare, and Check Point roles
#                 'cpAnsible' Module
#        NOTES:   Playbooks should be run by the owner of the project
#                 directory.
#       AUTHOR:   m87cyber, dev@m87cyber.com
#      VERSION:   0.2
#      CREATED:   31 Oct 2019
#     REVISION:   ---
#
#--------------------------------------------------------------------



#---------------------------------------------------------- _info --
# Display informative text 
#
function _info()
{
	cat <<- EOF
	  NAME
	       cpap - sample builder
	       $0 [-i] [-v]
	       $0
	  
	  
	  1 DESCRIPTION
	  *************
	  
	  This script would add the following items to the ansible
	  project directory
	     - inventory: 1 inventory file, 11 inventory var files
	     - scripts:   6 csv files, 3 bash scripts
	     - var files: 2 vmware var file, 2 chkp var files
	     - playbooks: 4 master playbooks, 4 sub_chkp playbooks
	  
	  All filenames would be prefixed by '${_env_tag}' taken as a
	  user input.
	  
	  The script can be run multiple times to create the same
	  number of files, at each run, for another environment, each
	  set of files being prefixed by the relevant environment tag.
	  
	  
	  1.1 master playbooks
	  --------------------
	  
	  4 master playbooks would be created for each environment
	  
	     [p-1] 1__${_env_tag}_create_api.yml
	     [p-2] 1__${_env_tag}_create_bash.yml
	     [p-3] 2__${_env_tag}_revert.yml
	     [p-4] 2__${_env_tag}_revert_clean.yml
	     
	  The first two playbooks would deploy the check point
	  security gateway by cloning a vm from the vm template,
	  performing the OS-level configuration, and provisioning a
	  security policy for the security gateway. 
	  
	  Provisioning the security policy includes creating the
	  security gateway object in the database of the security
	  management server as part of which SIC would be established
	  between the security gateway and the security management
	  server, creating a policy package, and installing the policy
	  package on the security gateway. 
	  
	  The last playbooks can be used to decommission the deployed
	  security gateway by removing the created policy package,
	  created objects, and the object of the gateway from the
	  security management server database and finally deleting the
	  created vm in the order mentioned.
	  
	  1.1.1 master playbooks dependencies
	  -----------------------------------
	  The sample master playbooks 'include' roles and 'import'
	  other playbooks to perform the required sequence of tasks.
	  The 'import'ed playbooks would be created through this
	  script; however, the 'includ'ed roles should already be in
	  place in the 'roles' folder before running master playbooks.
	  
	  '1__${_env_tag}_create_api.yml' takes advantage of API
	  calls from the Ansible server to the security management
	  server to perform security policy provisioning.  Hence,
	  running this playbook would depend on
	     - the availability of 'cpAnsible' module, and
	     - the security management server accepting API calls 
	       from the ansible server. 
	  
	  '1__${_env_tag}_create_bash.yml' performs the security
	  policy provisioning by running 2 bash scripts on the
	  security management server. The 2 bash scripts would be
	  created in the 'scripts/gaia' folder in the project
	  directory.
	  
	  
	  1.2 sub_chkp playbooks
	  ----------------------
	  
	  The following playbooks would be created under 'sub_chkp'
	  folders and would be 'import'ed as part of the master
	  playbook runs
	  
	     [p-5] __${_env_tag}_create_checkpoint_gw_api.yml
	     [p-6] __${_env_tag}_create_policy_package_api.yml
	     [p-7] __${_env_tag}_create_checkpoint_gw_bash.yml
	     [p-8] __${_env_tag}_create_policy_package_bash.yml
	  
	  If you want to modify the policy package and gateway object
	  definitions, you should start from
	  '__${_env_tag}_create_checkpoint_gw_api.yml' and
	  '__${_env_tag}_create_policy_package_api.yml' or the bash
	  scripts under the 'scripts/gaia' folder.
	  
	  
	  1.3 var files
	  -------------
	  
	  The following files would be created as variable containers
	  for playbooks
	  
	     [v-1] vmware_vars/${_env_tag}_vcsa_clone_vars.yml
	     [v-2] vmware_vars/${_env_tag}_vcsa_revert_vars.yml
	     [v-3] checkpoint_vars/${_env_tag}_gaia_config_vars.yml
	     [v-4] checkpoint_vars/${_env_tag}_policy_pkg_vars.yml
	  
	  These files are also an integral part of modifying policy
	  package and gateway definitions.  On a separate note, it
	  should be mentioned that [p-5] and [p-6] would automatically
	  remove/add Check Point mgmt API fingerprint from/to the
	  bottom of 'checkpoint_vars/${_env_tag}_policy_pkg_vars.yml'.
	  Furthermore, you need to revise the files inside 'vmware_vars'
	  to match your VMWare environment before running the 
	  playbooks.
	  
	  
	  1.4 scripts
	  -----------
	  
	  The following files would be created under 'scripts/gaia'.
	  
	     [s-1] scripts/gaia/${_env_tag}_create_chkp_gw.sh
	     [s-2] scripts/gaia/${_env_tag}_create_policy_package.sh
	     [s-3] scripts/gaia/${_env_tag}_chkp_revert.sh
	     [s-4] scripts/gaia/${_env_tag}_hosts.csv
	     [s-5] scripts/gaia/${_env_tag}_hosts_names.csv
	     [s-6] scripts/gaia/${_env_tag}_networks.csv
	     [s-7] scripts/gaia/${_env_tag}_networks_names.csv
	     [s-8] scripts/gaia/${_env_tag}_groups.csv
	     [s-9] scripts/gaia/${_env_tag}_groups_names.csv
	  
	  [p-7] and [p-8] transfer the 'csv' files to the security
	  management server after which they would directly run the
	  above bash scripts on the security management server. The
	  scripts would create/remove gateway object, host objects,
	  network objects, group objects, and policy package;
	  'scripts/gaia/${_env_tag}_create_policy_package.sh' would
	  also install the policy package on the gateway.  The 'csv'
	  files contain the specifications of the objects are needed
	  by the bash scripts.
	  
	  If you want to perform the security policy provisioning by
	  these bash scripts, instead of API calls from the ansible
	  server to the security management server, everything you
	  need is located under 'scripts/gaia' as well as [p-7] and
	  [p-8].
	  
	  
	  1.5 inventory
	  -------------
	  
	  The following files would be created as inventory and the
	  relevant variables
	  
	     [i-1]  ${_env_tag}_chkp
	     [i-2]  group_vars/localhost/vars
	     [i-3]  group_vars/localhost/vault
	     [i-4]  group_vars/os_gaia
	     [i-5]  host_vars/${_sms_ip}/vars
	     [i-6]  host_vars/${_sms_ip}/vault
	     [i-7]  host_vars/${_gw_ip}/vars
	     [i-8]  host_vars/${_gw_ip}/vault
	     [i-9]  host_vars/${_temp_gw_ip}/vars
	     [i-10]  host_vars/${_temp_gw_ip}/vault
	     [i-11] host_vars/${_vcsa_ip}/vars
	     [i-12] host_vars/${_vcsa_ip}/vault
	  
	  All files named 'vault' are ansible-vault encrypted with the
	  vault-id label and vault-id key taken from the user when the
	  script was run.
	  
	  
	  2 RUNNING THE PLAYBOOKS
	  ***********************
	  
	  The following items are required for running the playbooks 
	  generated by this script.
	  
	     - Check Point R80.x Security Management Server 
	     - VMWare vCenter 
	     - A Security GW Gaia R80.x VM template on the vCenter
	     - Sample General, VMWare, and Check Point roles
	     - 'cpAnsible' Module
	  
	  With the requirements in place, playbooks can be run with
	  the following syntax
	  
	     ansible-playbook <PLAYBOOK-ADDRESS> -i
	     ${_chkp_playbook_path}/${_env_tag}_chkp --vault-id
	     ${_vault_id_label}@${_vault_id_src}
	  
	  
	  2.1 examples
	  -------------
	  
	  Deploy the security gateway for an environment tagged by
	  'dev1' using the bash scripts
	  
	     ansible-playbook
	     /home/johndoe/ansible_dev/checkpoint/1__dev1_create_bash.yml
	     -i /home/johndoe/ansible_dev/checkpoint/dev1_chkp
	     --vault-id dev1@~/.ansible_vault/dev1_vault_pass
	  
	  Decommission the same gateway
	  
	     ansible-playbook
	     /home/johndoe/ansible_dev/checkpoint/2__dev1_revert_clean.yml
	     -i /home/johndoe/ansible_dev/checkpoint/dev1_chkp
	     --vault-id dev1@~/.ansible_vault/dev1_vault_pass
	  
	  Let's say you want to deploy another gateway for another
	  environment which is going to be tagged by 'dev2'.  You
	  should run this script once more, entering the relevant
	  information.  This would create another set of inventory
	  files, var file, playbooks, and scripts all tagged by
	  'dev2'.
	  Now you may execute the following line, for instance, to
	  deploy the new gateway.
	  
	     ansible-playbook
	     /home/johndoe/ansible_dev/checkpoint/1__dev2_create_api.yml
	     -i /home/johndoe/ansible_dev/checkpoint/dev2_chkp
	     --vault-id dev2@~/.ansible_vault/dev2_vault_pass
	  
	  In the above example, the security policy provisioning part
	  of the deployment would happen through API calls from the
	  ansible server to the security management server.
	  
	EOF
}


#---------------------------------------------------------- _err --
# Display error message and exit
#
function _err()
{
	local _err_msg
	_err_msg="${SCRIPT_TIMESTAMP}  [ ERROR ]  ${SCRIPT_NAME}: "
	_err_msg+="$1"
	echo "${_err_msg}"
	exit 1
}


#---------------------------------------------------------- _msg --
# Display informative message
#
function _msg()
{
	local _inf_msg
	_inf_msg="${SCRIPT_TIMESTAMP}  [ INFO ]  ${SCRIPT_NAME}: "
	_inf_msg+="$1"
	echo "${_inf_msg}"
}


#-------------------------------------------------- _add_ssh_key --
# Add ssh fingerprints to known_hosts
#
_add_ssh_key()
{
	ssh-keygen -R $1
	local FOUND_SSH_KEY="$(ssh-keyscan -T5 $1)"
	echo 
	echo "......................................................."
	echo "$FOUND_SSH_KEY" | fold -w 55
	echo "......................................................."
	echo "   The above ssh key was found for $1;"
	echo "   should this key be added to 'known_hosts'? (yes/no)"
	read _response
	if [[ ${_response} == "yes" ]]; then
	    ssh-keyscan -H $1 >> ~/.ssh/known_hosts
	    echo
	    _msg "ssh key added for $1"
	    echo
	fi
}



#--------------------------------------------------------------------
# Script definitions
#
set -e                                 # Exit when any command fails
SCRIPT_NAME="cpap - sample builder"
SCRIPT_VERSION="0.2"
SCRIPT_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SCRIPT_POSITIONAL=()


#--------------------------------------------------------------------
# Parsing script arguments
#
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	    -i|--information)
	        _info
	        exit 0
	        ;;
	    -v|--version)
	        _script_info="${SCRIPT_NAME} ${SCRIPT_VERSION}"
	        echo "${_script_info}"
	        exit 0
	        ;;
	    -*)
	        _err "Unknown flag $1."
	        ;;
	    *)
	        SCRIPT_POSITIONAL+=("$1")
	        shift           # jump over the argument
	        ;;
	esac
done
set -- "${SCRIPT_POSITIONAL[@]}"


#--------------------------------------------------------------------
# Confirming execution parameters
#
echo
echo "$(date)"
echo
echo "                  NAME : ${SCRIPT_NAME}"
echo "               VERSION : ${SCRIPT_VERSION}"
echo "              HOSTNAME : $(hostname)"
echo;echo
echo 'Press enter to continue ...'
read


#--------------------------------------------------------------------
# Reading user defined variables
#
echo
echo
echo "+----------------------------------------------------------+"
echo "|              Setting up some variables                   |"
echo "+----------------------------------------------------------+"
echo
echo '>> Enter Check Point Ansible project directory absolute path'
read -p '    ansible project directory: ' _chkp_playbook_path
if [[ ! -f "${_chkp_playbook_path}/0-apistatus.yml" ]]; then
    _err "'${_chkp_playbook_path}/0-apistatus.yml' does not exist."
fi
echo
echo ">> Enter the project owner login name"
read -p  '    project owner: ' _username
echo
_userhome_path="/home/${_username}"
if [[ "$(whoami)" != "${_username}" ]]; then
    _err "the script should be run by the owner of the project." 
fi
echo '-- inventory: Check Point  --------------------------------'
echo
echo '>> Enter SMS and GW Gaia version '
echo '   ( R80.10, R80.20, or R80.30 )'
read -p  '       Gaia version: ' _checkpoint_ver
echo '>> Enter the SMS specifications'
read -p  '         IP address: ' _sms_ip
read -p  '         login name: ' _sms_username
read -sp '           password: ' _sms_userpass
echo
echo '>> Enter GW template specifications'
read -p  '         IP address: ' _temp_gw_ip
echo '>> Enter the GW specifications '
read -p  '    Mgmt IP address: ' _gw_ip
read -p  '    Ext. IP address: ' _gw_ext_ip
read -p  '         login name: ' _gw_username
read -sp '           password: ' _gw_userpass
echo
echo '>> Other Check Point related specifications'
read -p  '    test static nat: ' _test_xlated_ip
echo
echo '-- inventory: VMWare  -------------------------------------'
echo
echo '>> Enter vCenter specifications'
read -p  '         IP address: ' _vcsa_ip
read -p  '           api port: ' _vcsa_api_port
read -p  '         login name: ' _vcsa_username
read -sp '           password: ' _vcsa_userpass
echo
echo
echo '-- inventory: Ansible  ------------------------------------'
echo
echo '>> Enter the Ansible server specifications (localhost)'
read -p  '        login name: ' _local_username
read -sp '          password: ' _local_userpass
echo
echo '>> Enter Ansible vault id specifications for this '
echo "   environment.  'vault id labels' are used to manage "
echo '   multiple vault secrets.'
echo '   (use something descriptive like dev1, dev2 , ... '
echo '    for the vault-id label)'
read -p  '    vault-id label: ' _vault_id_label
read -sp '      vault secret: ' _vault_secret
echo
echo
echo '-- filenames: tag -----------------------------------------'
echo
echo '>> Enter a tag for this environment'
read -p  '   environment tag: ' _env_tag
echo


#--------------------------------------------------------------------
# Creating the inventory
#
echo
echo
echo "+----------------------------------------------------------+"
echo "|               Creating the inventory                     |"
echo "+----------------------------------------------------------+"
declare -i i=1                             # an indexer for the tasks

echo
echo "+++ ($i) creating the vault-password-file ..."
echo
_vault_id_src="${_userhome_path}"/.ansible_vault/
_vault_id_src+="${_vault_id_label}"_vault_pass
if [[ ! -d "${_userhome_path}/.ansible_vault" ]]; then
    mkdir ${_userhome_path}/.ansible_vault
fi
echo "${_vault_secret}" > ${_vault_id_src}
chown -R ${_username}: ${_vault_id_src}
chmod -R u+w,g-r,o-r ${_vault_id_src}
_msg "vault id label for this inventory is '${_vault_id_label}'"
echo
declare -i i; i+=1

echo
echo "+++ ($i) creating '${_env_tag}_chkp' inventory file ..."
echo
cat <<EOF > ${_chkp_playbook_path}/${_env_tag}_chkp
# file: ${_env_tag}_chkp

[localhost]
127.0.0.1

[chkp_sms]
${_sms_ip}

[chkp_gw_template]
${_temp_gw_ip}

[chkp_gw]
${_gw_ip}

[os_gaia:children]
chkp_sms
chkp_gw_template
chkp_gw

[vmware_vcsa]
${_vcsa_ip}
EOF
declare -i i; i+=1

echo
echo "+++ ($i) creating 'localhost' group_vars ..."
echo
if [[ -d ${_chkp_playbook_path}/group_vars/localhost ]]; then
    rm -rf ${_chkp_playbook_path}/group_vars/localhost
fi
mkdir ${_chkp_playbook_path}/group_vars/localhost
cat <<EOF > ${_chkp_playbook_path}/group_vars/localhost/vars
---
# file: group_vars/localhost/vars
ansible_connection: local
ansible_host: 127.0.0.1
ansible_user: "{{ vault_ansible_user }}"
ansible_ssh_pass: "{{ vault_ansible_ssh_pass }}"
ansible_python_interpreter: /usr/bin/python2.7 
mgmt_server: ${_sms_ip}
mgmt_user: "{{ vault_mgmt_user }}"
mgmt_password: "{{ vault_mgmt_password }}"
EOF
cat <<EOF > ${_chkp_playbook_path}/group_vars/localhost/vault
---
# file: group_vars/localhost/vault
vault_ansible_user: '${_local_username}'
vault_ansible_ssh_pass: '${_local_userpass}'
vault_mgmt_user: '${_sms_username}'
vault_mgmt_password: '${_sms_userpass}'
EOF
ansible-vault encrypt ${_chkp_playbook_path}/group_vars/localhost/vault \
--vault-id ${_vault_id_label}@${_vault_id_src}
echo
declare -i i; i+=1

echo
echo "+++ ($i) creating 'os_gaia' group_vars ..." 
echo
if [[ ${_checkpoint_ver} == "R80.10" ]]; then
	cat <<- EOF > ${_chkp_playbook_path}/group_vars/os_gaia
	---
	# file: group_vars/os_gaia
	ansible_connection: ssh
	ansible_python_interpreter: /opt/CPsuite-R80/fw1/Python/bin/python
	EOF
else
	cat <<- EOF > ${_chkp_playbook_path}/group_vars/os_gaia
	---
	# file: group_vars/os_gaia
	ansible_connection: ssh
	ansible_python_interpreter: \
	/opt/CPsuite-${_checkpoint_ver}/fw1/Python/bin/python
	EOF
fi
declare -i i; i+=1

echo
echo "+++ ($i) creating 'chkp_sms' host_vars ..."
echo
if [[ -d ${_chkp_playbook_path}/host_vars/${_sms_ip} ]]; then
    rm -rf ${_chkp_playbook_path}/host_vars/${_sms_ip}
fi
mkdir ${_chkp_playbook_path}/host_vars/${_sms_ip}
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_sms_ip}/vars
---
# file: host_vars/${_sms_ip}/vars
ansible_user: "{{ vault_ansible_user }}"
ansible_ssh_pass: "{{ vault_ansible_ssh_pass }}"
EOF
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_sms_ip}/vault
---
# file: host_vars/${_sms_ip}/vault
vault_ansible_user: '${_sms_username}'
vault_ansible_ssh_pass: '${_sms_userpass}'
EOF
ansible-vault encrypt ${_chkp_playbook_path}/host_vars/${_sms_ip}/vault \
--vault-id ${_vault_id_label}@${_vault_id_src}
echo
declare -i i; i+=1

echo
echo "+++ ($i) creating 'chkp_gw' host_vars ..."
echo
if [[ -d ${_chkp_playbook_path}/host_vars/${_gw_ip} ]]; then
    rm -rf ${_chkp_playbook_path}/host_vars/${_gw_ip}
fi
mkdir ${_chkp_playbook_path}/host_vars/${_gw_ip}
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_gw_ip}/vars
---
# file: host_vars/${_gw_ip}/vars
ansible_user: "{{ vault_ansible_user }}"
ansible_ssh_pass: "{{ vault_ansible_ssh_pass }}"
EOF
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_gw_ip}/vault
---
# file: host_vars/${_gw_ip}/vault
vault_ansible_user: '${_gw_username}'
vault_ansible_ssh_pass: '${_gw_userpass}'
EOF
ansible-vault encrypt ${_chkp_playbook_path}/host_vars/${_gw_ip}/vault \
--vault-id ${_vault_id_label}@${_vault_id_src}
echo
declare -i i; i+=1

echo
echo "+++ ($i) creating 'chkp_gw_template' host_vars ..."
echo
if [[ -d ${_chkp_playbook_path}/host_vars/${_temp_gw_ip} ]]; then
    rm -rf ${_chkp_playbook_path}/host_vars/${_temp_gw_ip}
fi
mkdir ${_chkp_playbook_path}/host_vars/${_temp_gw_ip}
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_temp_gw_ip}/vars
---
# file: host_vars/${_temp_gw_ip}/vars
ansible_user: "{{ vault_ansible_user }}"
ansible_ssh_pass: "{{ vault_ansible_ssh_pass }}"
EOF
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_temp_gw_ip}/vault
---
# file: host_vars/${_gw_ip}/vault
vault_ansible_user: '${_gw_username}'
vault_ansible_ssh_pass: '${_gw_userpass}'
EOF
ansible-vault encrypt ${_chkp_playbook_path}/host_vars/${_temp_gw_ip}/vault \
--vault-id ${_vault_id_label}@${_vault_id_src}
echo
declare -i i; i+=1

echo
echo "+++ ($i) creating 'vmware_vcsa' host_vars ..."
echo
if [[ -d ${_chkp_playbook_path}/host_vars/${_vcsa_ip} ]]; then
    rm -rf ${_chkp_playbook_path}/host_vars/${_vcsa_ip}
fi
mkdir ${_chkp_playbook_path}/host_vars/${_vcsa_ip}
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_vcsa_ip}/vars
---
# file: host_vars/${_vcsa_ip}/vars
ansible_user: "{{ vault_ansible_user }}"
ansible_ssh_pass: "{{ vault_ansible_ssh_pass }}"
vcsa_address: ${_vcsa_ip}
vcsa_apiport: ${_vcsa_api_port}
vcsa_username: "{{ vault_vcsa_username }}"
vcsa_userpass: "{{ vault_vcsa_userpass }}"
EOF
cat <<EOF > ${_chkp_playbook_path}/host_vars/${_vcsa_ip}/vault
---
# file: host_vars/${_vcsa_ip}/vault
vault_ansible_user: '$_vcsa_username'
vault_ansible_ssh_pass: '${_vcsa_userpass}'
vault_vcsa_username: '$_vcsa_username'
vault_vcsa_userpass: '${_vcsa_userpass}'
EOF
ansible-vault encrypt ${_chkp_playbook_path}/host_vars/${_vcsa_ip}/vault \
--vault-id ${_vault_id_label}@${_vault_id_src}
echo
declare -i i; i+=1


#--------------------------------------------------------------------
# Creating the scripts
#
echo
echo "+----------------------------------------------------------+"
echo "|          Creating scripts called by playbooks            |"
echo "+----------------------------------------------------------+"
_scripts_path="${_chkp_playbook_path}/scripts"

echo
echo "+++ ($i) creating batch files for hosts, networks, and groups"
echo
echo "         scripts/gaia/${_env_tag}_hosts.csv"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_hosts.csv
name,ip-address,color,tags,comments
${_env_tag}_HOST_10.1.1.201,10.1.1.201,blue,${_env_tag},"GUI client"
${_env_tag}_HOST_172.16.1.101,172.16.1.101,cyan,${_env_tag},"Zabbix Server"
${_env_tag}_HOST_10.2.2.201,10.2.2.201,orange,${_env_tag},"MATE Client"
${_env_tag}_HOST_192.168.202.214,192.168.202.214,red,${_env_tag},"DNS Server"
${_env_tag}-CP-GW-Hide,${_gw_ext_ip},red,${_env_tag},
EOF

echo "         scripts/gaia/${_env_tag}_hosts_names.csv"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_hosts_names.csv
name,
${_env_tag}_HOST_10.1.1.201
${_env_tag}_HOST_172.16.1.101
${_env_tag}_HOST_10.2.2.201
${_env_tag}_HOST_192.168.202.214
${_env_tag}-CP-GW-Hide
EOF

echo "         scripts/gaia/${_env_tag}_networks.csv"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_networks.csv
name,subnet,subnet-mask,color,tags,comments
${_env_tag}_NET_192.168.202.0,192.168.202.0,255.255.255.0,red,${_env_tag},
${_env_tag}_NET_10.1.1.0,10.1.1.0,255.255.255.0,blue,${_env_tag},
${_env_tag}_NET_172.16.1.0,172.16.1.0,255.255.255.0,cyan,${_env_tag},
${_env_tag}_NET_10.2.2.0,10.2.2.0,255.255.255.0,orange,${_env_tag},
EOF

echo "         scripts/gaia/${_env_tag}_networks_names.csv"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_networks_names.csv
name,
${_env_tag}_NET_192.168.202.0
${_env_tag}_NET_10.1.1.0
${_env_tag}_NET_172.16.1.0
${_env_tag}_NET_10.2.2.0
EOF

echo "         scripts/gaia/${_env_tag}_groups.csv"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_groups.csv
name,members.add
${_env_tag}_internal_nets,${_env_tag}_NET_10.1.1.0
${_env_tag}_internal_nets,${_env_tag}_NET_172.16.1.0
${_env_tag}_internal_nets,${_env_tag}_NET_10.2.2.0
EOF

echo "         scripts/gaia/${_env_tag}_groups_names.csv"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_groups_names.csv
name,
${_env_tag}_internal_nets
EOF
declare -i i; i+=1


echo
echo "+++ ($i) creating 'mgmt_cli' bash scripts..."
echo "         scripts/gaia/${_env_tag}_create_chkp_gw.sh"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_create_chkp_gw.sh
#!/bin/bash
#...............................................................
# this bash script would create the gateway object on the SMS
# using 'mgmt_cli' commands which would locally engage the 
# automation server on the SMS.
#...............................................................

cd /home/${_sms_username}

mgmt_cli login -r true > id.txt

#---------------------------------------------------------------
# Modify the following line to change the definition of 
# the gateway object.
#
mgmt_cli add simple-gateway name "${_env_tag}-AU-CP-GW" \
ipv4-address "${_gw_ip}" \
color "blue" \
version "R80.30" \
firewall true vpn true ips true anti-bot true anti-virus true \
tags "${_env_tag}" \
one-time-password "vpn123" \
interfaces.1.name "eth0" \
interfaces.1.ipv4-address "${_gw_ip}" \
interfaces.1.ipv4-network-mask "255.255.255.0" \
interfaces.1.topology "internal" \
interfaces.1.anti-spoofing true \
interfaces.1.topology-settings.ip-address-behind-this-interface \
"network defined by the interface ip and net mask" \
interfaces.2.name "eth1" \
interfaces.2.ipv4-address "172.16.1.1" \
interfaces.2.ipv4-network-mask "255.255.255.0" \
interfaces.2.topology "internal" \
interfaces.2.anti-spoofing true \
interfaces.2.topology-settings.ip-address-behind-this-interface \
"network defined by the interface ip and net mask" \
interfaces.3.name "eth2" \
interfaces.3.ipv4-address "10.2.2.1" \
interfaces.3.ipv4-network-mask "255.255.255.0" \
interfaces.3.topology "internal" \
interfaces.3.anti-spoofing true \
interfaces.3.topology-settings.ip-address-behind-this-interface \
"network defined by the interface ip and net mask" \
interfaces.4.name "eth3" \
interfaces.4.ipv4-address "${_gw_ext_ip}" \
interfaces.4.ipv4-network-mask "255.255.255.0" \
interfaces.4.topology "external" \
interfaces.4.anti-spoofing true \
-s id.txt

mgmt_cli publish -s id.txt
mgmt_cli logout -s id.txt
EOF

echo "         scripts/gaia/${_env_tag}_create_policy_package.sh"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_create_policy_package.sh
#!/bin/bash
#...............................................................
# this bash script would perform the security policy
# provisioning using 'mgmt_cli' commands which would 
# directly engage the automation server on the SMS.
#...............................................................

cd /home/${_sms_username}

######################
# Login to a session #
######################
mgmt_cli login -r true > id.txt


###############
# Add objects #
###############
mgmt_cli add host --batch ${_env_tag}_hosts.csv -s id.txt
mgmt_cli set host name "${_env_tag}_HOST_172.16.1.101" \
nat-settings.auto-rule true \
nat-settings.ip-address "${_test_xlated_ip}" \
nat-settings.method static -s id.txt
mgmt_cli add network --batch ${_env_tag}_networks.csv -s id.txt
mgmt_cli add group --batch ${_env_tag}_groups_names.csv -s id.txt
mgmt_cli set group --batch ${_env_tag}_groups.csv -s id.txt


######################
# Add policy package #
######################
mgmt_cli add package name "${_env_tag}_policy_package" \
comments "Created by ansible for ${_env_tag}_chkp" \
color "green" threat-prevention "true" access "true" -s id.txt


####################
# Add access rules #
####################
mgmt_cli add access-section \
layer "${_env_tag}_policy_package Network" \
position "top" \
name "(1) management rules" \
-s id.txt

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "cp-gw management access" \
position.top "(1) management rules" \
source "${_env_tag}_HOST_10.1.1.201" \
destination "${_env_tag}-AU-CP-GW" \
service.1 "ssh" \
service.2 "https" \
action "accept" \
track "Log" \
-s id.txt

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "stealth rule" \
position.above "Cleanup rule" \
source "any" \
destination "${_env_tag}-AU-CP-GW" \
service "any" \
action "drop" \
track "Log" \
-s id.txt

mgmt_cli add access-section \
layer "${_env_tag}_policy_package Network" \
name "(2) internal-internal access rules" \
position.above "Cleanup rule" \
-s id.txt

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "access to DMZ1" \
position.top "(2) internal-internal access rules" \
source.1 "${_env_tag}_NET_10.1.1.0" \
source.2 "${_env_tag}_NET_10.2.2.0" \
destination "${_env_tag}_NET_172.16.1.0" \
service "any" \
action "accept" \
track "Log" \
-s id.txt

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "external access to zabbix" \
position.above "Cleanup rule" \
source "${_env_tag}_NET_192.168.202.0" \
destination "${_env_tag}_HOST_172.16.1.101" \
service "http" \
action "accept" \
track "Log" \
-s id.txt

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "zabbix access to internal nets" \
position.above "Cleanup rule" \
source "${_env_tag}_HOST_172.16.1.101" \
destination.1 "${_env_tag}_NET_10.1.1.0" \
destination.2 "${_env_tag}_NET_10.2.2.0" \
service "any" \
action "accept" \
track "Log" \
-s id.txt

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "block access to internal nets" \
position.above "Cleanup rule" \
source "any" \
destination "${_env_tag}_internal_nets" \
service "any" \
action "drop" \
track "Log" \
-s id.txt

mgmt_cli add access-section \
layer "${_env_tag}_policy_package Network" \
name "(3) internal-external access rules" \
position.above "Cleanup rule" \
-s id.txt  

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "dns queries" \
position.top "(3) internal-external access rules" \
source "${_env_tag}_internal_nets" \
destination "${_env_tag}_HOST_192.168.202.214" \
service "dns" \
action "accept" \
track "Log" \
-s id.txt

mgmt_cli add access-rule \
layer "${_env_tag}_policy_package Network" \
name "Internet access" \
position.above "Cleanup rule" \
source "${_env_tag}_internal_nets" \
destination "any" \
service.1 "http" \
service.2 "https" \
action "accept" \
track "Log" \
-s id.txt

mgmt_cli add access-section \
layer "${_env_tag}_policy_package Network" \
name "default drop" \
position.above "Cleanup rule" \
-s id.txt


#################
# Add NAT rules #
#################
mgmt_cli add nat-section \
package "${_env_tag}_policy_package" \
name "${_env_tag}_chkp manual NAT rules" \
position "top" \
-s id.txt

mgmt_cli add nat-rule \
package "${_env_tag}_policy_package" \
comments "Internal subnets NAT" \
position.top "${_env_tag}_chkp manual NAT rules" \
original-source "${_env_tag}_internal_nets" \
original-destination "${_env_tag}_internal_nets" \
-s id.txt

mgmt_cli add nat-rule \
package "${_env_tag}_policy_package" \
comments "Internal subnets NAT" \
position.bottom "${_env_tag}_chkp manual NAT rules" \
original-source "${_env_tag}_internal_nets" \
translated-source "${_env_tag}-CP-GW-Hide" \
method "hide" -s id.txt


###################
# Publish changes #
###################
mgmt_cli publish -s id.txt


##################
# Install Policy #
##################
mgmt_cli install-policy \
policy-package "${_env_tag}_policy_package" \
access "true" threat-prevention "false" \
targets "${_env_tag}-AU-CP-GW" \
-s id.txt

mgmt_cli install-policy \
policy-package "${_env_tag}_policy_package" \
access "false" threat-prevention "true" \
targets "${_env_tag}-AU-CP-GW" \
-s id.txt


#########################
# Logout of the session #
#########################
mgmt_cli logout -s id.txt
EOF

echo "         scripts/gaia/${_env_tag}_chkp_revert.sh"
cat <<EOF > ${_scripts_path}/gaia/${_env_tag}_chkp_revert.sh
#!/bin/bash
#...............................................................
# this bash script would remove the created policy package,
# the gateway object, group objects, host obects, and 
# network objects from the SMS database.
#...............................................................

cd /home/${_sms_username}

mgmt_cli login -r true > id.txt

mgmt_cli delete package \
name "${_env_tag}_policy_package" \
-s id.txt

mgmt_cli delete simple-gateway \
name "${_env_tag}-AU-CP-GW" \
-s id.txt

mgmt_cli delete group \
--batch ${_env_tag}_groups_names.csv \
-s id.txt

mgmt_cli delete host \
--batch ${_env_tag}_hosts_names.csv \
-s id.txt

mgmt_cli delete network \
--batch ${_env_tag}_networks_names.csv \
-s id.txt

mgmt_cli publish -s id.txt
mgmt_cli logout -s id.txt
EOF
declare -i i; i+=1


#--------------------------------------------------------------------
# Creating the var files
#
echo
echo "+----------------------------------------------------------+"
echo "|          Creating VMware and Check Point vars            |"
echo "+----------------------------------------------------------+"
echo
_vmware_vars_path="${_chkp_playbook_path}/vmware_vars"
_chkp_vars_path="${_chkp_playbook_path}/checkpoint_vars"
echo
echo "+++ ($i) creating 'vmware_vars' ..."
if [[ ! -d ${_vmware_vars_path} ]]; then
    mkdir ${_vmware_vars_path}
fi
echo "         ${_env_tag}_vcsa_clone_vars.yml"
cat <<EOF > ${_vmware_vars_path}/${_env_tag}_vcsa_clone_vars.yml
---
# file: vmware_vars/${_env_tag}_vcsa_clone_vars.yml
#...............................................................
# review the following variables and 
# modify them according to your environment.
#...............................................................
# these varaibles will be used by VMWare roles
# to clone the gateway from a vm template and to
# modify the seetings of the vm.
#...............................................................

vcenter_hostname: "{{ vcsa_address }}"
vcenter_port: "{{ vcsa_apiport }}"
vcenter_username: "{{ vcsa_username }}"
vcenter_password: "{{ vcsa_userpass }}"
datacenter_name: TNCTDXBLAB
datacenter_folder: _vm_/labs/Automation
vm_name: ${_env_tag}-AU-CP-GW
template_name: AU-CP-GW-R8030
virtual_machine_datastore: ESXi-202-SSD7-1
virtual_machine_rss_pool: _${_env_tag}_LAB_AUTOMATION
# memory_mb_value:
# num_cpus_vlue:
# num_cpu_cores_per_socket_value:
# scsi_value:
# memory_reservation_lock_value:
# mem_limit_value:
# mem_reservation_value:
# cpu_limit_value:
# cpu_reservation_value:
# max_connections_value:
# hotadd_cpu_value:
# hotremove_cpu_value:
# hotadd_memory:
# version_value:
# boot_firmware_value:
# cdrom_type_value:
# cdrom_iso_path_value:
# vm_network_name:
# vm_network_mac_address:
port_group_name_mgmt: AU_LAB_MGMT
port_group_name_dmz: ${_env_tag}_AU_LAB_DMZ
port_group_name_user: ${_env_tag}_AU_LAB_USER
port_group_name_vmnet: VM Network
wait_for_ip_address_value: YES
snapshot_datacenter_name: TNCTDXBLAB
snapshot_name_value: 00-BASE
snapshot_description: "chkp gw r8030 base installed image; mgmt if 
                       is configured with a non-default ip-address"
envtag: $_env_tag
EOF

echo "         ${_env_tag}_vcsa_revert_vars.yml"
cat <<EOF > ${_vmware_vars_path}/${_env_tag}_vcsa_revert_vars.yml
---
# file: vmware_vars/${_env_tag}_vcsa_revert_vars.yml
#...............................................................
# review the following variables and 
# modify them according to your environment.
#...............................................................
# these varaibles will be used by VMWare roles
# to delete the gateway vm and revert the SMS to 
# the base snapshot if '2__${_env_tag}_revert.yml'
# is played.
#...............................................................

vcenter_hostname: "{{ vcsa_address }}"
vcenter_port: "{{ vcsa_apiport }}"
vcenter_username: "{{ vcsa_username }}"
vcenter_password: "{{ vcsa_userpass }}"
gw_vm_uuid: "{{ gw_vm_params.instance.hw_product_uuid }}"
sms_snapshot_datacenter_name: TNCTDXBLAB
sms_datacenter_name: TNCTDXBLAB
sms_datacenter_folder: _vm_/labs/Automation
sms_vm_name: AU-CP-SMS
sms_base_snapshot_name: 00-BASE
EOF
declare -i i; i+=1


echo
echo "+++ ($i) Creating 'checkpoint_vars' ..."
if [[ ! -d ${_chkp_vars_path} ]]; then
    mkdir ${_chkp_vars_path}
fi
echo "         ${_env_tag}_gaia_config_vars.yml"
cat <<EOF > ${_chkp_vars_path}/${_env_tag}_gaia_config_vars.yml
---
# file: checkpoint_vars/${_env_tag}_gaia_config_vars.yml
#...............................................................
# review the following variables and 
# modify them according to your environment.
#...............................................................
# these varaibles will be used by Check Point roles
# to perform the OS-level configuration of the gateway.
#...............................................................

interfaces_config:
  interface1:
    if_name: eth1
    if_ipv4: 172.16.1.1
    if_masklength: 24
  interface2:
    if_name: eth2
    if_ipv4: 10.2.2.1
    if_masklength: 24
  interface3:
    if_name: eth3
    if_ipv4: ${_gw_ext_ip}
    if_masklength: 24


# dhcp_client_config:
  # dhcpclient1:
    # if_name: eth3

dns_config:
  dns:
    dns1: 192.168.202.214
    dns2: 8.8.8.8

ntp_config:
  ntp:
    ntp1: 0.pool.ntp.org
    ntp1_ver: 4

hostname: ${_env_tag}-AU-CP-GW
sickey: vpn123
timezone: America/New_York

static_route_config:
  address1:
    dst: default
    next_hop_address: 192.168.202.1
    state: on
    priority: 1
  address2:
    dst: 192.168.201.0/24
    next_hop_address: 192.168.202.254
    state: on

EOF

echo "         ${_env_tag}_policy_pkg_vars.yml"
cat <<EOF > ${_chkp_vars_path}/${_env_tag}_policy_pkg_vars.yml
---
# file: checkpoint_vars/${_env_tag}_policy_pkg_vars.yml
#...............................................................
# review the following variables and 
# modify them according to your environment.
#...............................................................
# these varaibles will be used by sub_chkp 
# plabooks for security policy provisioning.
#...............................................................

# GW object specs
gw_obj_name: ${_env_tag}-AU-CP-GW \
# this should be the same as the gateway's hostname
gw_obj_ipv4address: ${_gw_ip}
gw_sic_key: vpn123
gw_obj_eth0_ipv4: ${_gw_ip}
gw_obj_eth0_ipv4_mask: 255.255.255.0
gw_obj_eth1_ipv4: 172.16.1.1
gw_obj_eth1_ipv4_mask: 255.255.255.0
gw_obj_eth2_ipv4: 10.2.2.1
gw_obj_eth2_ipv4_mask: 255.255.255.0
gw_obj_eth3_ipv4: ${_gw_ext_ip}
gw_obj_eth3_ipv4_mask: 255.255.255.0
# Policy package specs
plc_pkg_name: ${_env_tag}_policy_package
plc_pkg_comment: "Created by ansible for ${_env_tag}_chkp"
# Networks
external_subnet_name: ${_env_tag}_NET_192.168.202.0
external_subnet_cidr: 192.168.202.0/24
mgmt_subnet_name: ${_env_tag}_NET_10.1.1.0
mgmt_subnet_cidr: 10.1.1.0/24
dmz1_subnet_name: ${_env_tag}_NET_172.16.1.0
dmz1_subnet_cidr: 172.16.1.0/24
users_subnet_name: ${_env_tag}_NET_10.2.2.0
users_subnet_cidr: 10.2.2.0/24
# Hosts
host1_name: ${_env_tag}_HOST_10.1.1.201
host1_ip: 10.1.1.201
host1_comments: "GUI client"
host2_name: ${_env_tag}_HOST_172.16.1.101
host2_ip: 172.16.1.101
host2_comments: "Zabbix Server"
host3_name: ${_env_tag}_HOST_10.2.2.201
host3_ip: 10.2.2.201
host3_comments: "MATE Client"
host4_name: ${_env_tag}_HOST_192.168.202.214
host4_ip: 192.168.202.214
host4_comments: "DNS Server"
perimeter_gw_external_if_name: ${_env_tag}-CP-GW-Hide
perimeter_gw_external_if_ip: ${_gw_ext_ip}
# api fingerprint
EOF
declare -i i; i+=1


#--------------------------------------------------------------------
# Creating the playbooks
#
echo
echo "+----------------------------------------------------------+"
echo "|         Creating master playbooks and sub-plays          |"
echo "+----------------------------------------------------------+"
echo
_subchkp_plays_path="${_chkp_playbook_path}/sub_chkp"
echo
echo "+++ ($i) Creating the playbooks ..."
echo "         1__${_env_tag}_create_api.yml"
cat <<EOF > ${_chkp_playbook_path}/1__${_env_tag}_create_api.yml
---
# file: 1__${_env_tag}_create_api.yml
#...............................................................
# this playbook would 
#  - clone the gateway from template by including VMWare roles
#  - configure Gaia by including Check Point roles
#  - perfrom the security policy provisioning by importing
#     > 'sub_chkp/__${_env_tag}_create_checkpoint_gw_api.yml'
#     > 'sub_chkp/__${_env_tag}_create_policy_package_api.yml'
#...............................................................

- name: ${_env_tag}_chkp Deployment
  gather_facts: no
  hosts: all

- hosts: vmware_vcsa
  gather_facts: no
  tasks:
  # Cloning the R80.30 GW VM
  - name: calling the required variabls for cloning vm from template 
    include_vars:
      file: vmware_vars/${_env_tag}_vcsa_clone_vars.yml
  - include_role:
      name: 1_1__vmware_guest_clone

- hosts: localhost
  gather_facts: no
  tasks:
  # Adding cloned GW temp ip_address to 'known_hosts' on localhost
  - include_role:
      name: 0_1__add_ssh_key
    vars:
      server_address: ${_temp_gw_ip}

- hosts: chkp_gw_template
  gather_facts: no
  vars_files:
  - checkpoint_vars/${_env_tag}_gaia_config_vars.yml
  tasks:
  # Setting shell to bash
  - include_role:
      name: 2_1__set_bash
  # Configuring Interfaces
  - include_role:
      name: 2_2__set_interface
  # Changing the ip-address of the management interface
  - name: changing ip address of the mgmt interface of the gateway
    shell: clish -c "set interface eth0 ipv4-address ${_gw_ip} mask-length 24"
    ignore_errors: yes
    async: 1
    poll: 0

- hosts: localhost
  gather_facts: no
  tasks:
  # Adding cloned GW new ip_address to 'known_hosts' on localhost
  - include_role:
      name: 0_1__add_ssh_key
    vars:
      server_address: ${_gw_ip}

- hosts: chkp_gw
  gather_facts: no
  vars_files:
  - checkpoint_vars/${_env_tag}_gaia_config_vars.yml
  tasks:
  # Saving configuration
  - name: saving configuration
    shell: clish -c "save config"
  # # Configuring dhcp Interfaces
    # - include_role:
        # name: 2_3__add_dhcp_client
  # Configuring DNS and NTP
  - include_role:
      name: 2_4__set_dns
  - include_role:
      name: 2_5__set_ntp
  # First-time Wizard
  - include_role:
      name: 2_6__gateway_ftw

# Creating the Gateway Object and installing policy
- name: creating the gateway object and installing policy
  import_playbook: sub_chkp/__${_env_tag}_create_checkpoint_gw_api.yml

# Creating the Policy Package
- name: creating the policy package
  import_playbook: sub_chkp/__${_env_tag}_create_policy_package_api.yml

EOF

echo "         1__${_env_tag}_create_bash.yml"
cat <<EOF > ${_chkp_playbook_path}/1__${_env_tag}_create_bash.yml
---
# file: 1__${_env_tag}_create_bash.yml
#...............................................................
# this playbook would 
#  - clone the gateway from template by including VMWare roles
#  - configure Gaia by including Check Point roles
#  - perfrom the security policy provisioning by importing
#     > 'sub_chkp/__${_env_tag}_create_checkpoint_gw_bash.yml'
#     > 'sub_chkp/__${_env_tag}_create_policy_package_bash.yml'
#...............................................................

- name: ${_env_tag}_chkp Deployment
  gather_facts: no
  hosts: all

- hosts: vmware_vcsa
  gather_facts: no
  tasks:
  # Cloning the R80.30 GW VM
  - name: calling the required variabls for cloning vm from template 
    include_vars:
      file: vmware_vars/${_env_tag}_vcsa_clone_vars.yml
  - include_role:
      name: 1_1__vmware_guest_clone

- hosts: localhost
  gather_facts: no
  tasks:
  # Adding cloned GW temp ip_address to 'known_hosts' on localhost
  - include_role:
      name: 0_1__add_ssh_key
    vars:
      server_address: ${_temp_gw_ip}

- hosts: chkp_gw_template
  gather_facts: no
  vars_files:
  - checkpoint_vars/${_env_tag}_gaia_config_vars.yml
  tasks:
  # Setting shell to bash
  - include_role:
      name: 2_1__set_bash
  # Configuring Interfaces
  - include_role:
      name: 2_2__set_interface
  # Changing the ip-address of the management interface
  - name: changing ip address of the mgmt interface of the gateway
    shell: clish -c "set interface eth0 ipv4-address ${_gw_ip} mask-length 24"
    ignore_errors: yes
    async: 1
    poll: 0

- hosts: localhost
  gather_facts: no
  tasks:
  # Adding cloned GW new ip_address to 'known_hosts' on localhost
  - include_role:
      name: 0_1__add_ssh_key
    vars:
      server_address: ${_gw_ip}

- hosts: chkp_gw
  gather_facts: no
  vars_files:
  - checkpoint_vars/${_env_tag}_gaia_config_vars.yml
  tasks:
  # Saving configuration
  - name: saving configuration
    shell: clish -c "save config"
  # # Configuring dhcp Interfaces
    # - include_role:
        # name: 2_3__add_dhcp_client
  # Configuring DNS and NTP
  - include_role:
      name: 2_4__set_dns
  - include_role:
      name: 2_5__set_ntp
  # First-time Wizard
  - include_role:
      name: 2_6__gateway_ftw

# Creating the Gateway Object and installing policy
- name: creating the gateway object and installing policy
  import_playbook: sub_chkp/__${_env_tag}_create_checkpoint_gw_bash.yml

# Creating the Policy Package
- name: creating the policy package
  import_playbook: sub_chkp/__${_env_tag}_create_policy_package_bash.yml

EOF

echo "         2__${_env_tag}_revert.yml"
cat <<EOF > ${_chkp_playbook_path}/2__${_env_tag}_revert.yml
---
# file: 2__${_env_tag}_revert.yml
#...............................................................
# this playbook would 
#  - shutdown and delete the gateway vm
#  - revert the SMS to the base snapshot
#...............................................................

- name: ${_env_tag}_chkp Revert to base state
  gather_facts: no
  hosts: vmware_vcsa

  tasks:
  - name: Calling CP-GW VM variabls
    include_vars:
      file: vmware_vars/${_env_tag}_deployed_gw_vm_facts.yml
      name: gw_vm_params

  - name: Calling VMware related variables
    include_vars:
      file: vmware_vars/${_env_tag}_vcsa_revert_vars.yml

  - debug:
      msg: "{{ gw_vm_params }}"

  - include_role:
      name: 1_2__vmware_guest_revert

EOF

echo "         2__${_env_tag}_revert_clean.yml"
cat <<EOF > ${_chkp_playbook_path}/2__${_env_tag}_revert_clean.yml
---
# file: 2__${_env_tag}_revert_clean.yml
#...............................................................
# this playbook would 
#  - run '${_env_tag}_chkp_revert.sh' on the SMS to
#       > remove all created objects on the SMS database
#  - delete the gateway vm
#...............................................................

- hosts: ${_sms_ip}
  gather_facts: no
  connection: local

  tasks:
  - name: "Copying ${_env_tag}_hosts_names.csv, \
${_env_tag}_networks_names.csv, \
and ${_env_tag}_groups_names.csv to ${_sms_ip}"
    copy:
      src: "{{ item }}"
      dest: /home/${_sms_username}/
    with_items:
      - ${_scripts_path}/gaia/${_env_tag}_hosts_names.csv
      - ${_scripts_path}/gaia/${_env_tag}_networks_names.csv
      - ${_scripts_path}/gaia/${_env_tag}_groups_names.csv

  - name: "Running scripts/gaia/${_env_tag}_chkp_revert.sh on ${_sms_ip}"
    script: ${_scripts_path}/gaia/${_env_tag}_chkp_revert.sh
    register: output

  - debug: var=output.stdout_lines

- hosts: vmware_vcsa
  gather_facts: no

  tasks:
  - name: Calling CP-GW VM variabls
    include_vars:
      file: vmware_vars/${_env_tag}_deployed_gw_vm_facts.yml
      name: gw_vm_params

  - name: Calling VMware related variables
    include_vars:
      file: vmware_vars/${_env_tag}_vcsa_revert_vars.yml

  - debug:
      msg: "{{ gw_vm_params }}"

  - include_role:
      name: 1_3__vmware_guest_revert_gw_only

EOF

echo "         sub_chkp/__${_env_tag}_create_checkpoint_gw_api.yml"
cat <<EOF > ${_subchkp_plays_path}/__${_env_tag}_create_checkpoint_gw_api.yml
---
# file: sub_chkp/__${_env_tag}_create_checkpoint_gw_api.yml
#...............................................................
# * engaging remote api calls *
#   -------------------------
#   this playbook would 
#     - add chkp mgmt api fingerprint to the relevant var file
#     - create the gateway object on the SMS database 
#...............................................................

- hosts: chkp_sms
  gather_facts: no
  connection: local

  tasks:
  - name: "extracting api fingerprint"
    shell: "api fingerprint | grep SHA1 | cut -c 7-"
    register: result
  - debug:
      msg: "{{ result }}"

  - name: "making sure 'mgmt_api_fingerprint' is removed from \
'${_env_tag}_policy_pkg_vars.yml'"
    lineinfile:
      path: ${_chkp_vars_path}/${_env_tag}_policy_pkg_vars.yml
      state: absent
      regexp: '^mgmt_api_fingerprint'
    delegate_to: localhost

  - name: "making sure the new 'mgmt_api_fingerprint' is added \
to '${_env_tag}_policy_pkg_vars.yml'"
    lineinfile:
      path: ${_chkp_vars_path}/${_env_tag}_policy_pkg_vars.yml
      line: "mgmt_api_fingerprint: {{ result.stdout }}"
    delegate_to: localhost

- hosts: localhost
  gather_facts: no
  connection: local
  vars_files:
  - ${_chkp_vars_path}/${_env_tag}_policy_pkg_vars.yml

  tasks:
  - name: Wait up to 300 seconds for SIC port 18211 to Open
    wait_for:
      port: 18211
      host: ${_gw_ip}
      delay: 10
    connection: local

  - name: "login"
    check_point_mgmt:
      command: login
      parameters:
        username: "{{ mgmt_user }}"
        password: "{{ mgmt_password }}"
        management: "{{ mgmt_server }}"
      fingerprint: "{{ mgmt_api_fingerprint }}"
    register: login_response

  - name: "Create SimpleGateway"
    check_point_mgmt:
      command: add-simple-gateway 
      parameters:
        name: "{{ gw_obj_name }}"
        ipv4-address: "{{ gw_obj_ipv4address }}" 
        color: blue
        tags: "${_env_tag}"
        firewall: "true"
        version: "R80.30"
        ips: "true"
        one-time-password: "{{ gw_sic_key }}"
        interfaces:
        -  name: eth0
           ipv4-address: "{{ gw_obj_eth0_ipv4 }}" 
           ipv4-network-mask: "{{ gw_obj_eth0_ipv4_mask }}"
           topology: Internal
           anti-spoofing: "true"
           topology-settings:
             ip-address-behind-this-interface: \
"network defined by the interface ip and net mask"
        -  name: eth1
           ipv4-address: "{{ gw_obj_eth1_ipv4 }}" 
           ipv4-network-mask: "{{ gw_obj_eth1_ipv4_mask }}"
           topology: Internal
           anti-spoofing: "true"
           topology-settings:
             ip-address-behind-this-interface: \
"network defined by the interface ip and net mask"
        -  name: eth2
           ipv4-address: "{{ gw_obj_eth2_ipv4 }}" 
           ipv4-network-mask: "{{ gw_obj_eth2_ipv4_mask }}"
           topology: Internal
           anti-spoofing: "true"
           topology-settings:
             ip-address-behind-this-interface: \
"network defined by the interface ip and net mask"
        -  name: eth3
           ipv4-address: "{{ gw_obj_eth3_ipv4 }}" 
           ipv4-network-mask: "{{ gw_obj_eth3_ipv4_mask }}"
           topology: External
           anti-spoofing: "true"
      session-data: "{{ login_response }}"

  - name: "publish"
    check_point_mgmt:
      command: publish
      session-data: "{{ login_response }}"

  - name: "logout"
    check_point_mgmt:
      command: logout
      session-data: "{{ login_response }}"
EOF

echo "         sub_chkp/__${_env_tag}_create_policy_package_api.yml"
cat <<EOF > ${_subchkp_plays_path}/__${_env_tag}_create_policy_package_api.yml
---
# file: sub_chkp/__${_env_tag}_create_policy_package_api.yml
#...............................................................
# * engaging remote api calls *
#   -------------------------
#   this playbook would
#     - add chkp mgmt api fingerprint to the relevant var file
#     - create all necessary objects on the SMS database 
#     - create a policy package for the gateway on the 
#       SMS database
#     - install policy on the gateway 
#...............................................................

- hosts: chkp_sms
  gather_facts: no
  connection: local

  tasks:
  - name: "extracting api fingerprint"
    shell: "api fingerprint | grep SHA1 | cut -c 7-"
    register: result
  - debug:
      msg: "{{ result }}"

  - name: "making sure 'mgmt_api_fingerprint' is removed from \
'${_env_tag}_policy_pkg_vars.yml'"
    lineinfile:
      path: ${_chkp_vars_path}/${_env_tag}_policy_pkg_vars.yml
      state: absent
      regexp: '^mgmt_api_fingerprint'
    delegate_to: localhost

  - name: "making sure the new 'mgmt_api_fingerprint' is added to \
'${_env_tag}_policy_pkg_vars.yml'"
    lineinfile:
      path: ${_chkp_vars_path}/${_env_tag}_policy_pkg_vars.yml
      line: "mgmt_api_fingerprint: {{ result.stdout }}"
    delegate_to: localhost


- hosts: localhost
  gather_facts: no
  connection: local
  vars_files:
  - ${_chkp_vars_path}/${_env_tag}_policy_pkg_vars.yml

  tasks:
  - name: "login"
    check_point_mgmt:
      command: login
      parameters:
        username: "{{ mgmt_user }}"
        password: "{{ mgmt_password }}"
        management: "{{ mgmt_server }}"
      fingerprint: "{{ mgmt_api_fingerprint }}"
    register: login_response

# Adding the policy package
  - name: "create-new-policy-package"
    check_point_mgmt:
      command: add-package
      parameters:
        name: "{{ plc_pkg_name }}"
        comments: "{{ plc_pkg_comment }}"
        color: "green"
        threat-prevention: "true"
        access: "true"
      session-data: "{{ login_response }}"

# Adding networks
  - name: "add the external subnet"
    check_point_mgmt:
      command: add-network
      parameters:
        name: "{{ external_subnet_name }}"
        subnet: "{{ external_subnet_cidr | ipaddr('network') }}" 
        subnet-mask: "{{ external_subnet_cidr | ipaddr('netmask') }}"
        color: "red"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

  - name: "add the management subnet"
    check_point_mgmt:
      command: add-network
      parameters:
        name: "{{ mgmt_subnet_name }}"
        subnet: "{{ mgmt_subnet_cidr | ipaddr('network') }}" 
        subnet-mask: "{{ mgmt_subnet_cidr | ipaddr('netmask') }}"
#        groups: "${_env_tag}_internal_nets"
        color: "blue"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

  - name: "add DMZ1 subnet"
    check_point_mgmt:
      command: add-network
      parameters:
        name: "{{ dmz1_subnet_name }}"
        subnet: "{{ dmz1_subnet_cidr | ipaddr('network') }}" 
        subnet-mask: "{{ dmz1_subnet_cidr | ipaddr('netmask') }}"
#        groups: "${_env_tag}_internal_nets"
        color: "cyan"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

  - name: "add Users subnet"
    check_point_mgmt:
      command: add-network
      parameters:
        name: "{{ users_subnet_name }}"
        subnet: "{{ users_subnet_cidr | ipaddr('network') }}" 
        subnet-mask: "{{ users_subnet_cidr | ipaddr('netmask') }}"
#        groups: "${_env_tag}_internal_nets"
        color: "orange"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

# Adding hosts     
  - name: "add GUI-CLNT host"
    check_point_mgmt:
      command: add-host
      parameters:
        name: "{{ host1_name }}"
        ip-address: "{{ host1_ip }}"
        color: "blue"
        comments: "{{ host1_comments }}"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

  - name: "add Zabbix-Server host"
    check_point_mgmt:
      command: add-host
      parameters:
        name: "{{ host2_name }}"
        ip-address: "{{ host2_ip }}"
        color: "cyan"
        nat-settings:
          auto-rule: true
          method: "static"
          ipv4-address: ${_test_xlated_ip}
        comments: "{{ host2_comments }}"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

  - name: "add CLNT-01 host"
    check_point_mgmt:
      command: add-host
      parameters:
        name: "{{ host3_name }}"
        ip-address: "{{ host3_ip }}"
        color: "orange"
        comments: "{{ host3_comments }}"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

  - name: "add DNS-Server host"
    check_point_mgmt:
      command: add-host
      parameters:
        name: "{{ host4_name }}"
        ip-address: "{{ host4_ip }}"
        color: "red"
        comments: "{{ host4_comments }}"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

  - name: "add Hide_NAT host"
    check_point_mgmt:
      command: add-host
      parameters:
        name: "{{ perimeter_gw_external_if_name }}"
        ip-address: "{{ perimeter_gw_external_if_ip }}"
        color: "red"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

# Adding groups
  - name: "add-internal-nets-group"
    check_point_mgmt:
      command: add-group
      parameters:
        name: "${_env_tag}_internal_nets"
        members:
          - "{{ mgmt_subnet_name }}"
          - "{{ dmz1_subnet_name }}"
          - "{{ users_subnet_name }}"
        tags: "${_env_tag}"
      session-data: "{{ login_response }}"

# Adding access rules
  - name: "add access section management rules"
    check_point_mgmt:
      command: add-access-section
      parameters:
        layer: "{{ plc_pkg_name }} Network"
        name: "(1) management rules"
        position: "top"
      session-data: "{{ login_response }}"

  - name: "add access rule for Gateway management"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name }} Network"
        name: "cp-gw management access"
        position:
          top: "(1) management rules"
        source:
          - "{{ host1_name }}"
        destination:
          - "{{ gw_obj_name }}"
        service:
          - "ssh"
          - "https"
        action: "accept"
        track: "Log"
      session-data: "{{ login_response }}"

  - name: "add stealth rule"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name }} Network"
        name: "stealth rule"
        position:
          above: "Cleanup rule"
        source:
          - "any"
        destination:
          - "{{ gw_obj_name }}"
        service:
          - "any"
        action: "drop"
        track: "Log"
      session-data: "{{ login_response }}"
      
  - name: "add access section (2) internal-internal access rules"
    check_point_mgmt:
      command: add-access-section
      parameters:
        layer: "{{ plc_pkg_name }} Network"
        name: "(2) internal-internal access rules"
        position:
          above: "Cleanup rule"   
      session-data: "{{ login_response }}"

  - name: "add access rule from Users and Management subnets to DMZ1 subnet"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name  }} Network"
        name: "access to DMZ1"
        position:
          top: "(2) internal-internal access rules"
        source:
          - "{{ mgmt_subnet_name }}"
          - "{{ users_subnet_name }}"
        destination:
          - "{{ dmz1_subnet_name }}"
        service:
          - "any"
        action: "accept"
        track: "Log"
      session-data: "{{ login_response }}"

  - name: "add access rule from external network to zabbix"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name  }} Network"
        name: "external access to zabbix"
        position:
          above: "Cleanup rule"
        source:
          - "{{ external_subnet_name }}"
        destination:
          - "{{ host2_name }}"
        service:
          - "http"
        action: "accept"
        track: "Log"
      session-data: "{{ login_response }}"

  - name: "add access rule from Zabbix to Users and Management subnets"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name  }} Network"
        name: "zabbix access to internal nets"
        position:
          above: "Cleanup rule"
        source:
          - "{{ host2_name }}"
        destination:
          - "{{ mgmt_subnet_name }}"
          - "{{ users_subnet_name }}"
        service:
          - "any"
        action: "accept"
        track: "Log"
      session-data: "{{ login_response }}"

  - name: "add access rule from any to Internal subnets"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name }} Network"
        name: "block access to internal nets"
        position:
          above: "Cleanup rule"
        source:
          - "any"
        destination:
          - "${_env_tag}_internal_nets"
        service:
          - "any"
        action: "drop"
        track: "Log"
      session-data: "{{ login_response }}"

  - name: "add access section Internal-External access rules"
    check_point_mgmt:
      command: add-access-section
      parameters:
        layer: "{{ plc_pkg_name }} Network"
        name: "(3) internal-external access rules"
        position:
          above: "Cleanup rule"   
      session-data: "{{ login_response }}"

  - name: "add access rule from internal to dns"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name  }} Network"
        name: "dns queries"
        position:
          top: "(3) internal-external access rules"
        source:
          - "${_env_tag}_internal_nets"
        destination:
          - "{{ host4_name }}"
        service:
          - "dns"
        action: "accept"
        track: "Log"
      session-data: "{{ login_response }}"

  - name: "add access rule from internal to any for http, https"
    check_point_mgmt:
      command: add-access-rule
      parameters:
        layer: "{{ plc_pkg_name  }} Network"
        name: "Internet access"
        position:
          above: "Cleanup rule"
        source:
          - "${_env_tag}_internal_nets"
        destination:
          - "any"
        service:
          - "http"
          - "https"
        action: "accept"
        track: "Log"
      session-data: "{{ login_response }}"

  - name: "add access section default drop"
    check_point_mgmt:
      command: add-access-section
      parameters:
        layer: "{{ plc_pkg_name }} Network"
        name: "default drop"
        position:
          above: "Cleanup rule"   
      session-data: "{{ login_response }}"


# Adding NAT rules
  - name: "add NAT section"
    check_point_mgmt:
      command: add-nat-section
      parameters:
        package: "{{ plc_pkg_name }}"
        name: "${_env_tag}_chkp manual NAT rules"
        position: "top"
      session-data: "{{ login_response }}"

  - name: "add no NAT rule for Internal subnets to Internal subnets"
    check_point_mgmt:
      command: add-nat-rule
      parameters:
        package: "{{ plc_pkg_name }}"
        comments: "Internal subnets NAT"
        position:
          top: "${_env_tag}_chkp manual NAT rules"
        original-source: "${_env_tag}_internal_nets"
        original-destination: "${_env_tag}_internal_nets"
      session-data: "{{ login_response }}"

  - name: "add NAT rule for Internal subnets to any networks"
    check_point_mgmt:
      command: add-nat-rule
      parameters:
        package: "{{ plc_pkg_name }}"
        comments: "Internal subnets NAT"
        position:
          bottom: "${_env_tag}_chkp manual NAT rules"
        original-source: "${_env_tag}_internal_nets"
        translated-source: "{{ perimeter_gw_external_if_name }}"
        method: "hide"
      session-data: "{{ login_response }}"

# Publish changes
  - name: "publish"
    check_point_mgmt:
      command: publish
      session-data: "{{ login_response }}"

# Install policy
  - name: "Push Access Policy"
    check_point_mgmt:
      command: install-policy
      parameters:
        policy-package: "{{ plc_pkg_name }}"
        access: "true"
        threat-prevention: "false"
        targets:
          -  "{{ gw_obj_name }}"
      session-data: "{{ login_response }}"

  - name: "Push Threat Policy"
    check_point_mgmt:
      command: install-policy
      parameters:
        policy-package: "{{ plc_pkg_name }}"
        access: "false"
        threat-prevention: "true"
        targets:
          -  "{{ gw_obj_name }}"
      session-data: "{{ login_response }}"

# Logout of the session
  - name: "logout"
    check_point_mgmt:
      command: logout
      session-data: "{{ login_response }}"
EOF

echo "         sub_chkp/__${_env_tag}_create_checkpoint_gw_bash.yml"
cat <<EOF > ${_subchkp_plays_path}/__${_env_tag}_create_checkpoint_gw_bash.yml
---
# sub_chkp/__${_env_tag}_create_checkpoint_gw_bash.yml
#...............................................................
# * taking advantage of bash *
#   ------------------------
#   this playbook would
#     - run '${_env_tag}_create_chkp_gw.sh' on the SMS to
#          > create the gateway object on the SMS database
#...............................................................

- hosts: localhost
  gather_facts: no
  connection: local

  tasks:
  - name: Wait up to 300 seconds for SIC port 18211 to Open
    wait_for:
      port: 18211
      host: ${_gw_ip}
      delay: 10
    connection: local

- hosts: ${_sms_ip}
  gather_facts: no
  connection: local

  tasks:
  - name: "Running scripts/gaia/${_env_tag}_create_chkp_gw.sh on ${_sms_ip}"
    script: ${_scripts_path}/gaia/${_env_tag}_create_chkp_gw.sh
    register: output

  - debug: var=output.stdout_lines
EOF

echo "         sub_chkp/__${_env_tag}_create_policy_package_bash.yml"
cat <<EOF > ${_subchkp_plays_path}/__${_env_tag}_create_policy_package_bash.yml
---
# file: sub_chkp/__${_env_tag}_create_policy_package_bash.yml
#...............................................................
# * taking advantage of bash *
#   ------------------------
#   this playbook would
#     - transfer four csv files to the SMS
#     - run '${_env_tag}_create_policy_package.sh' on the SMS to 
#          > create all necessary objects on the SMS database
#          > create a policy package for the gateway on the SMS 
#            database
#          > install policy on the gateway 
#...............................................................

- hosts: ${_sms_ip}
  gather_facts: no
  connection: local

  tasks:
  - name: "Copying ${_env_tag}_hosts.csv, ${_env_tag}_networks.csv, \
and ${_env_tag}_groups.csv to ${_sms_ip}"
    copy:
      src: "{{ item }}"
      dest: /home/${_sms_username}/
    with_items:
      - ${_scripts_path}/gaia/${_env_tag}_hosts.csv
      - ${_scripts_path}/gaia/${_env_tag}_networks.csv
      - ${_scripts_path}/gaia/${_env_tag}_groups_names.csv
      - ${_scripts_path}/gaia/${_env_tag}_groups.csv

  - name: "Running scripts/gaia/${_env_tag}_create_policy_package.sh \
on ${_sms_ip}"
    script: ${_scripts_path}/gaia/${_env_tag}_create_policy_package.sh
    register: output

  - debug: var=output.stdout_lines

EOF
declare -i i; i+=1


#--------------------------------------------------------------------
# Should we play 0-apistatus.yml
#
echo
echo "+----------------------------------------------------------+"
echo "|         Playing the 0-apistatus.yml playbook             |"
echo "+----------------------------------------------------------+"
echo
echo "+++ (I) adding CP-SMS ssh key to 'known_hosts' ...."
echo
if [[ ! -d ~/.ssh ]]; then
    mkdir ~/.ssh
fi
touch ~/.ssh/known_hosts
_add_ssh_key ${_sms_ip}

echo "    Do you want to play '0-apistatus.yml'? (yes/no)"
read response
if [[ $response == "yes" ]]; then
    echo
    echo "+++ (II) playing '0-apistatus.yml' ...."
    echo
    ANSIBLE_DEBUG=1 ansible-playbook ${_chkp_playbook_path}/0-apistatus.yml \
    -i ${_chkp_playbook_path}/${_env_tag}_chkp \
    --vault-id ${_vault_id_label}@${_vault_id_src} \
    | tee ${_chkp_playbook_path}/0-apistatus.log
    
    API_STATUS="$(ansible-playbook ${_chkp_playbook_path}/0-apistatus.yml \
    -i ${_chkp_playbook_path}/${_env_tag}_chkp \
    --vault-id ${_vault_id_label}@${_vault_id_src} | grep '\"stdout\":')"

  if [[ $API_STATUS == *"Started"* ]]; then
      echo
      echo "    -----------------------------------------------------------    "
      echo "    CONGRATULATIONS!" 
      echo "The API is ready!! now you can play with ANSIBLE \
press Enter to continue .... " | fold -s -w 55 | sed -e "s|^|\t|g"
      echo "    -----------------------------------------------------------    "
      echo
      read continue
  else
    echo
    echo "**INFO** The API is not ready yet ..." 
    echo
    read continue
  fi
fi


#--------------------------------------------------------------------
# Project is Ready
#
_msg_header="    ---------------------- "
_msg_header+="YOUR PROJECT IS READY"
_msg_header+=" ----------------------   "
_msg_body_I="Relevant inventory, scripts, var files, and playbooks"
_msg_body_I+=" have been added to Check Point Ansible project directory."
_msg_body_I+="  Playbooks can be run using the following"
_msg_body_I+=" ansible-playbook command:"
_msg_body_II="$(whoami)@$(hostname):~$ ansible-playbook <PLAYBOOK-ADDRESS>"
_msg_body_II+=" -i ${_chkp_playbook_path}/${_env_tag}_chkp "
_msg_body_II+="--vault-id ${_vault_id_label}@${_vault_id_src}"
_msg_footer="    ----------------------------------"
_msg_footer+="---------------------------------    "
echo "${_msg_header}" 
echo "${_msg_body_I}" | fold -s -w 65 | sed -e "s|^|\t|g"
echo
echo "${_msg_body_II}" | fold -s -w 65 | sed -e "s|^|\t|g"
echo "${_msg_footer}"

exit 0

# END
