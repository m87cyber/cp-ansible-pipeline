#!/bin/bash
#
#--------------------------------------------------------------------
#
#         NAME:   1_cpap_directory_builder.sh
#
#        USAGE:   bash 1_cpap_directory_builder.sh [-h] [-v] [-G] 
#                                                  [-V] [-C] [-m] 
#
#  DESCRIPTION:   Create a sample ansible project directory layout. 
#
# REQUIREMENTS:   root permission
#        NOTES:   Specific customized roles, as well as the 'cpAnsible'
#                 library could be deployed, as part of the execution.
#       AUTHOR:   m87cyber, dev@m87cyber.com
#      VERSION:   0.2
#      CREATED:   31 Oct 2019
#     REVISION:   ---
#
#--------------------------------------------------------------------



#---------------------------------------------------------- _usage --
# Display help text 
#
function _usage()
{
	cat <<- EOF
	Usage: $0 [-h] [-v] [-G] [-V] [-C] [-m]
	       $0
	Example: $0 -G -C -m 

	Description:
	Create a sample ansible project directory with ansible naming
	conventions for 'inventory' variables, roles, and library directories.
	Separate directories would be created for variables to be called during
	playbook runs. 

	Options:
	   -h, --help                   display this help text and exit
	   -v, --version                display version information and exit
	   -G, --add-general-roles      add sample general roles
	   -V, --add-vmware-roles       add sample VMWare roles
	   -C, --add-checkpoint-roles   add sample Check Point roles
	   -m, --add-cpasnible-lib      add 'cpAnsible' module

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



#--------------------------------------------------------------------
# Script definitions
#
set -e                                 # Exit when any command fails
SCRIPT_NAME="cpap - directory layout builder"
SCRIPT_VERSION="0.2"
SCRIPT_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SCRIPT_POSITIONAL=()
ADD_GENERAL_ROLES="no"
ADD_VMWARE_ROLES="no"
ADD_CHKP_ROLES="no"
ADD_CPANSIBLE_LIB="no"


#--------------------------------------------------------------------
# Checking the requirements
#
if [[ $EUID -ne 0 ]]; then
	 _err "This script must be run as root."
fi


#--------------------------------------------------------------------
# Parsing script arguments
#
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	    -h|--help)
	        _usage
	        exit 0
	        ;;
	    -v|--version)
	        _script_info="${SCRIPT_NAME} ${SCRIPT_VERSION}"
	        echo "${_script_info}"
	        exit 0
	        ;;
	    -G|--add-general-roles)
	        ADD_GENERAL_ROLES="yes"
	        shift           # jump over the flag 
	        ;;
	    -V|--add-vmware-roles)
	        ADD_VMWARE_ROLES="yes"
	        shift           # jump over the flag
	        ;;
	    -C|--add-checkpoint-roles)
	        ADD_CHKP_ROLES="yes"
	        shift
	        ;;
	    -m|--add-cpasnible-lib)
	        ADD_CPANSIBLE_LIB="yes"
	        shift
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
echo "     ADD GENERAL ROLES : ${ADD_GENERAL_ROLES}"
echo "      ADD VMWARE ROLES : ${ADD_VMWARE_ROLES}"
echo " ADD CHECK POINT ROLES : ${ADD_CHKP_ROLES}"
echo "     ADD CPANSIBLE LIB : ${ADD_CPANSIBLE_LIB}"
echo;echo
echo 'Press enter to continue ...'
read



#--------------------------------------------------------------------
# Reading user defined variables
#
echo;echo
echo "+----------------------------------------------------------+"
echo "|                 Setting up some variables                |"
echo "+----------------------------------------------------------+"
echo
echo '>> Enter the name of an existing user on this machine who'
echo '   would be the owner of the project directory.'
read -p  '    project owner username: ' _project_owner
echo
USERDIR="/home/${_project_owner}"
if id "${_project_owner}" > /dev/null 2>&1; then
	_msg="${SCRIPT_TIMESTAMP} [ INFO ] ${SCRIPT_NAME}:\n"
	_msg+="        $USERDIR will be used as the parent directory\n" 
	_msg+="        to store the ansible vault password files."
	echo -e "${_msg}"
else 
   exit 1
fi
echo
cat << EOF
The following directory layout would be created 

root/checkpoint/
|---host_vars/        # variables for inventories host entries
|
|---group_vars/       # variables for inventories group entries
|
|---library/          # location of additional modules
|   |
|   ...check_point_mgmt.py  # <-- 'cpAnsible' library
|
|---roles/            # user defined roles
|   |
|   ....0_X__Y        # General
|   ....1_X__Y        # VMware
|   ....2_X__Y        # Check Point
|
|---vmware_vars/      # VMware variables needed by roles and playbooks
|
|---checkpoint_vars/  # Check Point variables needed by roles and playbooks
|
|---scripts/          # scripts to be run on targets
|   |
|   |---gaia/
|
|---sub_chkp/         # Check Point playbooks to be called by master
|                        playbooks
|                        
|...0-apistatus.yml   # <-- sample playbook to test chkp mgmt api status

EOF
echo ">> Enter a directory path relative to '$USERDIR'"
echo "   for building the above ansible project"
read -p  '    project directory path (root): ' _project_rel_path
_project_path="$USERDIR/${_project_rel_path}"
_chkp_project_path="${_project_path}/checkpoint"
INITIALCHKPARAMETERS="        parameters = parameters.replace"
INITIALCHKPARAMETERS+="(\"None\", \"null\")"
AFTERINITIALCHKPARAMETERS="        parameters = parameters.replace"
AFTERINITIALCHKPARAMETERS+="(\"None\", \"null\")\n        "
AFTERINITIALCHKPARAMETERS+="parameters = parameters.replace(\"'\", '\"')"
COMMAND="bash -lc 'api status' | awk '\$0~/API Status/{print \$4}'"



#--------------------------------------------------------------------
# Creating the sample directory layout 
# 
echo;echo
echo "+----------------------------------------------------------+"
echo "|      Creating the Ansible project directory layout       |"
echo "+----------------------------------------------------------+"
declare -i i=1                             # an indexer for the tasks


echo
echo "+++ ($i) creating all the directries ...."
echo
if [[ -d "${_chkp_project_path}" ]]; then
   rm -rf ${_chkp_project_path}
fi
mkdir -p ${_chkp_project_path}/group_vars
mkdir ${_chkp_project_path}/host_vars
mkdir ${_chkp_project_path}/library
mkdir ${_chkp_project_path}/roles
mkdir ${_chkp_project_path}/vmware_vars
mkdir ${_chkp_project_path}/checkpoint_vars
mkdir ${_chkp_project_path}/sub_chkp
mkdir -p ${_chkp_project_path}/scripts/gaia
_role_path="${_chkp_project_path}/roles"
declare -i i; i+=1


#---- adding custom modules ------------------------------------------
# 
#
if [[ ${ADD_CPANSIBLE_LIB} == "yes" ]]; then
	#
	# cpAnsible module
	#
	echo
	echo "+++ ($i) deploying the 'cpAnsible' module ...."
	echo
	cd /etc/ansible
	if [[ -d "/etc/ansible/cpAnsible" ]]; then
	    rm -rf /etc/ansible/cpAnsible
	fi
	git clone --recursive https://github.com/CheckPointSW/cpAnsible 
	mv -f /etc/ansible/cpAnsible/check_point_mgmt/check_point_mgmt.py \
	   ${_chkp_project_path}/library/check_point_mgmt.py
	sed -i "s~$INITIALCHKPARAMETERS~$AFTERINITIALCHKPARAMETERS~" \
	${_chkp_project_path}/library/check_point_mgmt.py
	pip install \
	    git+https://github.com/CheckPointSW/cp_mgmt_api_python_sdk
	pip install --upgrade \
	    git+https://github.com/CheckPointSW/cp_mgmt_api_python_sdk
	declare -i i; i+=1
fi


#---- adding custom General roles ------------------------------------
#
#
if [[ ${ADD_GENERAL_ROLES} == "yes" ]]; then
	#
	# 0_1__add_ssh_key
	#
	echo
	echo "+++ ($i) creating 0_x__y roles for system sequential tasks ...."
	echo "         0_1__add_ssh_key"
	_0_1_role_path="${_role_path}/0_1__add_ssh_key"
	if [[ -d ${_0_1_role_path} ]];then
	    rm -rf ${_0_1_role_path}
	fi
	mkdir -p ${_0_1_role_path}/defaults
	mkdir ${_0_1_role_path}/tasks
	cat <<- EOF > ${_0_1_role_path}/defaults/main.yml
	---
	# file: roles/0_1__add_ssh_key/defaults/main.yml
	gather_facts: no
	connection: local
	EOF
	cat <<- EOF > ${_0_1_role_path}/tasks/main.yml
	---
	# file: roles/0_1__add_ssh_key/tasks/main.yml
	- name: "waiting up to 120 seconds for ssh port 22 to open on \
'{{ server_address }}'"
	  wait_for:
	    port: 22
	    host: "{{ server_address }}"
	    delay: 10
	    timeout: 120
	  connection: local

	- name: "removing ssh fingerprint of '{{ server_address }}', \
if it exists in 'known_hosts'"
	  command: ssh-keygen -R "{{ server_address }}"
	  ignore_errors: yes

	- name: "fetching '{{ server_address }}' ssh key "
	  command: ssh-keyscan -H -T5 "{{ server_address }}"
	  register: keyscan
	  failed_when: keyscan.rc != 0 or keyscan.stdout == ''
	  changed_when: False
	- debug:
	    msg: "{{ keyscan.stdout }}"

	- pause:
	    prompt: "(WARNING):: \
should the above ssh key be added to 'known_hosts'? (yes/no)"
	    echo: yes
	  register: result

	- name: "adding '{{ server_address }}' ssh-key to local 'known_hosts'"
	  lineinfile:
	    name: ~/.ssh/known_hosts
	#   create: yes
	    line: "{{ item }}"
	  when: result.user_input == "yes"
	  with_items: '{{ keyscan.stdout_lines|default([]) }}'
	EOF
	declare -i i; i+=1
fi


#---- adding custom VMWare roles -------------------------------------
# 
#
if [[ ${ADD_VMWARE_ROLES} == "yes" ]]; then
	#
	# 1_1__vmware_guest_clone
	#
	echo
	echo "+++ ($i) creating 1_x__y roles for VMware sequential tasks ...."
	echo "         1_1__vmware_guest_clone"
	_1_1_role_path="${_role_path}/1_1__vmware_guest_clone"
	if [[ -d ${_1_1_role_path} ]]; then
	    rm -rf ${_1_1_role_path}
	fi
	mkdir -p ${_1_1_role_path}/defaults
	mkdir ${_1_1_role_path}/tasks
	cat <<- EOF > ${_1_1_role_path}/defaults/main.yml
	---
	# file: roles/1_1__vmware_guest_clone/defaults/main.yml
	# gather_facts: no
	connection: local
	EOF
	cat <<- EOF > ${_1_1_role_path}/tasks/main.yml
	---
	# file: roles/1_1__vmware_guest_clone/tasks/main.yml
	- name: Create a virtual machine from a template
	  vmware_guest:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    validate_certs: no
	    datacenter: "{{ datacenter_name }}"
	    folder: "{{ datacenter_folder }}"
	    name: "{{ vm_name }}"
	    state: poweredon
	    template: "{{ template_name }}"
	    datastore: "{{ virtual_machine_datastore }}"
	    resource_pool: "{{ virtual_machine_rss_pool }}"
	    # hardware:
	      # memory_mb: "{{ memory_mb_value }}"
	      # num_cpus: "{{ num_cpus_vlue }}"
	      # num_cpu_cores_per_socket: "{{ num_cpu_cores_per_socket_value }}"
	      # scsi: "{{ scsi_value }}"
	      # memory_reservation_lock: "{{ memory_reservation_lock_value }}"
	      # mem_limit: "{{ mem_limit_value }}"
	      # mem_reservation: "{{ mem_reservation_value }}"
	      # cpu_limit: "{{ cpu_limit_value }}"
	      # cpu_reservation: "{{ cpu_reservation_value }}"
	      # max_connections: "{{ max_connections_value }}"
	      # hotadd_cpu: "{{ hotadd_cpu_value }}"
	      # hotremove_cpu: "{{ hotremove_cpu_value }}"
	      # hotadd_memory: "{{ hotadd_memory }}"
	      # version: "{{ version_value }}"  \
# Hardware version of the virtual machine
	      # boot_firmware: "{{ boot_firmware_value }}"
	    # cdrom:
	      # type: "{{ cdrom_type_value }}"
	      # iso_path: "{{ cdrom_iso_path_value }}"
	    networks:
	    - name: "{{ port_group_name_mgmt }}"
	    - name: "{{ port_group_name_dmz }}"
	    - name: "{{ port_group_name_user }}"
	    - name: "{{ port_group_name_vmnet }}"        
	    wait_for_ip_address: "{{ wait_for_ip_address_value }}"
	  delegate_to: localhost
	  register: deploy

	- name: Removing the gw_vm_facts file if it exists
	  local_action: file \
path=vmware_vars/{{ envtag }}_deployed_gw_vm_facts.yml \
state=absent

	- name: Copying the deployed vm facts to a file
	  local_action: copy \
content="{{ deploy }}" \
dest=vmware_vars/{{ envtag }}_deployed_gw_vm_facts.yml

	- name: Removing the gw_vm_uuid file if it exists
	  local_action: file \
path=vmware_vars/{{ envtag }}_deployed_gw_vm_uuid \
state=absent

	- name: Copying uuid of the deployed vm to a file
	  local_action: copy \
content="{{ deploy.instance.hw_product_uuid }}" \
dest=vmware_vars/{{ envtag }}_deployed_gw_vm_uuid

	- name: Create the base snapshot
	  vmware_guest_snapshot:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    validate_certs: no
	    datacenter: "{{ snapshot_datacenter_name }}"
	    uuid: "{{ deploy.instance.hw_product_uuid }}"
	    state: present
	    snapshot_name: "{{ snapshot_name_value }}"
	    description: "{{ snapshot_description }}"
	  delegate_to: localhost
	  when: deploy.instance.hw_product_uuid is defined
	EOF
	#
	# 1_2__vmware_guest_revert
	#
	echo "         1_2__vmware_guest_revert"
	_1_2_role_path="${_role_path}/1_2__vmware_guest_revert"
	if [[ -d ${_1_2_role_path} ]]; then
	    rm -rf ${_1_2_role_path}
	fi
	mkdir -p ${_1_2_role_path}/defaults
	mkdir ${_1_2_role_path}/tasks
	cat <<- EOF > ${_1_2_role_path}/defaults/main.yml
	---
	# file: roles/1_2__vmware_guest_revert/defaults/main.yml
	# gather_facts: no
	connection: local
	EOF
	cat <<- EOF > ${_1_2_role_path}/tasks/main.yml
	---
	# file: roles/1_2__vmware_guest_revert/tasks/main.yml

	# Powering off the GW VM
	- name: set the powerstate of the GW to poweredoff
	  vmware_guest:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    validate_certs: no
	    uuid: "{{ gw_vm_uuid }}"
	    state: poweredoff
	  delegate_to: localhost

	# Removing the GW VM
	- name: remove the GW VM 
	  vmware_guest:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    validate_certs: no
	    uuid: "{{ gw_vm_uuid }}"
	    state: absent
	  delegate_to: localhost

	# Reverting SMS to the base snapshot
	- name: revert sms to base snapshot
	  vmware_guest_snapshot:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    validate_certs: no
	    datacenter: "{{ sms_snapshot_datacenter_name }}"
	    folder: "{{ sms_datacenter_folder }}"
	    name: "{{ sms_vm_name }}"
	    state: revert
	    snapshot_name: "{{ sms_base_snapshot_name }}" 
	  delegate_to: localhost

	# Powering on the SMS VM
	- name: set the powerstate of the SMS to poweredon
	  vmware_guest:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    datacenter: "{{ sms_datacenter_name }}"
	    folder: "{{ sms_datacenter_folder }}"
	    name: "{{ sms_vm_name }}"
	    validate_certs: no
	    state: poweredon
	  delegate_to: localhost
	EOF
	#
	# 1_3__vmware_guest_revert_gw_only
	#
	echo "         1_3__vmware_guest_revert_gw_only"
	_1_3_role_path="${_role_path}/1_3__vmware_guest_revert_gw_only"
	if [[ -d ${_1_3_role_path} ]]; then
	    rm -rf ${_1_3_role_path}
	fi
	mkdir -p ${_1_3_role_path}/defaults
	mkdir ${_1_3_role_path}/tasks
	cat <<- EOF > ${_1_3_role_path}/defaults/main.yml
	---
	# file: roles/1_3__vmware_guest_revert_gw_only/defaults/main.yml
	# gather_facts: no
	connection: local
	EOF
	cat <<- EOF > ${_1_3_role_path}/tasks/main.yml
	---
	# file: roles/1_3__vmware_guest_revert_gw_only/tasks/main.yml

	# Powering off the GW VM
	- name: set the powerstate of the GW to poweredoff
	  vmware_guest:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    validate_certs: no
	    uuid: "{{ gw_vm_uuid }}"
	    state: poweredoff
	  delegate_to: localhost

	# Removing the GW VM
	- name: remove the GW VM 
	  vmware_guest:
	    hostname: "{{ vcenter_hostname }}"
	    port: "{{ vcenter_port }}"
	    username: "{{ vcenter_username }}"
	    password: "{{ vcenter_password }}"
	    validate_certs: no
	    uuid: "{{ gw_vm_uuid }}"
	    state: absent
	  delegate_to: localhost

	EOF
	declare -i i; i+=1
fi


#---- adding custom Check Point role----------------------------------
# 
#
if [[ ${ADD_CHKP_ROLES} == "yes" ]]; then
	#
	# 2_1_set_bash 
	#
	echo
	echo "+++ ($i) creating 2_x__y roles for GW deployments ...."
	echo "         2_1__set_bash"
	_2_1_role_path="${_role_path}/2_1__set_bash"
	if [[ -d ${_2_1_role_path} ]]; then
	    rm -rf ${_2_1_role_path}
	fi
	mkdir -p ${_2_1_role_path}/defaults
	mkdir ${_2_1_role_path}/tasks
	cat <<- EOF > ${_2_1_role_path}/defaults/main.yml
	---
	# file: roles/2_1__set_bash/defaults/main.yml
	gather_facts: no
	connection: local
	EOF
	cat <<- EOF > ${_2_1_role_path}/tasks/main.yml
	---
	# file: roles/2_1__set_bash/tasks/main.yml
	- name: "Checking if we are connected to bash"
	  raw: ps -p$$ -ocmd=
	  register: shell_output 
	  ignore_errors: yes

	- name: "set shell"
	  raw: set user admin shell /bin/bash
	  when: "'CLINFR0329' in shell_output.stdout"

	- name: "save config"
	  raw: save config
	  when: "'CLINFR0329' in shell_output.stdout"

	- name: Waiting for 65 seconds to clear SSH session
	  pause:
	    seconds: 65
	  when: "'CLINFR0329' in shell_output.stdout"
	EOF
	#
	# 2_2__set_interface
	#
	echo "         2_2__set_interface"
	_2_2_role_path="${_role_path}/2_2__set_interface"
	if [[ -d ${_2_2_role_path} ]];then
	    rm -rf ${_2_2_role_path}
	fi
	mkdir -p ${_2_2_role_path}/defaults
	mkdir ${_2_2_role_path}/tasks
	cat <<- EOF > ${_2_2_role_path}/defaults/main.yml
	---
	# file: roles/2_2__set_interface/defaults/main.yml
	gather_facts: no
	connection: local
	set_interface_syntax: "clish -c 
	                         'set interface {{ item.value.if_name }} 
	                          ipv4-address {{ item.value.if_ipv4 }} 
	                          mask-length \
	                          {{ item.value.if_masklength }}' -s 
	                          && clish -c 
	                          'set interface {{ item.value.if_name }} \
	                          state on' -s " 
	EOF
	cat <<- EOF > ${_2_2_role_path}/tasks/main.yml
	---
	# file: roles/2_2__set_interface/tasks/main.yml
	- name: "Configuring Interfaces and change their state to on"
	  shell: "{{ set_interface_syntax }}"
	  with_dict: "{{ interfaces_config }}"
	EOF
	#
	# 2_3__add_dhcp_client
	#
	echo "         2_3__add_dhcp_client"
	_2_3_role_path="${_role_path}/2_3__add_dhcp_client"
	if [[ -d ${_2_3_role_path} ]]; then
	    rm -rf ${_2_3_role_path}
	fi
	mkdir -p ${_2_3_role_path}/defaults
	mkdir ${_2_3_role_path}/tasks
	cat <<- EOF > ${_2_3_role_path}/defaults/main.yml
	---
	# file: roles/2_3__add_dhcp_client/defaults/main.yml
	gather_facts: no
	connection: local
	add_dhcp_client_syntax: "clish -c 
	                          'add dhcp client 
	                           interface {{ item.value.if_name }}' -s 
	                           && clish -c 
	                          'set interface {{ item.value.if_name }} 
	                          state on' -s " 
	EOF
	cat <<- EOF > ${_2_3_role_path}/tasks/main.yml
	---
	# file: roles/2_3__add_dhcp_client/tasks/main.yml
	- name: "Configure the dhcp client interface and change state to on"
	  shell: "{{ add_dhcp_client_syntax }}"
	  with_dict: "{{ dhcp_client_config }}"
	EOF
	#
	# 2_4__set_dns
	#
	echo "         2_4__set_dns"
	_2_4_role_path="${_role_path}/2_4__set_dns"
	if [[ -d ${_2_4_role_path} ]]; then
	    rm -rf ${_2_4_role_path}
	fi
	mkdir -p ${_2_4_role_path}/defaults
	mkdir ${_2_4_role_path}/tasks
	cat <<- EOF > ${_2_4_role_path}/defaults/main.yml
	---
	# file: roles/2_4__set_dns/defaults/main.yml
	gather_facts: no
	connection: local
	set_dns_syntax_1: "clish -c 'set dns primary {{ item.value.dns1 }}' -s"
	set_dns_syntax_2: "clish -c 'set dns primary {{ item.value.dns1 }}' -s 
	                   && clish -c 'set dns secondary {{ item.value.dns2 }}' -s"
	set_dns_syntax_3: "clish -c 'set dns primary {{ item.value.dns1 }}' -s 
	                   && clish -c 'set dns secondary {{ item.value.dns2 }}' -s 
	                   && clish -c 'set dns tertiary {{ item.value.dns3 }}' -s"
	EOF
	cat <<- EOF > ${_2_4_role_path}/tasks/main.yml
	---
	# file: roles/2_4__set_dns/tasks/main.yml
	- name: "Configure dns settings"
	  shell: "{{ set_dns_syntax_1 }}"
	  with_dict: "{{ dns_config }}"
	  when:
	    - dns_config.dns.dns1 is defined
	    - not (dns_config.dns.dns2 is defined \
and dns_config.dns.dns3 is defined)

	- name: "Configure dns settings"
	  shell: "{{ set_dns_syntax_2 }}"
	  with_dict: "{{ dns_config }}"
	  when:
	    - dns_config.dns1 is defined
	    - dns_config.dns2 is defined
	    - dns_config.dns3 is not defined

	- name: "Configure dns settings"
	  shell: "{{ set_dns_syntax_3 }}"
	  with_dict: "{{ dns_config }}"
	  when:
	    - dns_config.dns1 is defined
	    - dns_config.dns2 is defined
	    - dns_config.dns3 is defined
	EOF
	#
	# 2_5__set_ntp
	#
	_2_5_role_path="${_role_path}/2_5__set_ntp"
	if [[ -d ${_2_5_role_path} ]]; then
	    rm -rf ${_2_5_role_path}
	fi
	echo "         2_5__set_ntp"
	mkdir -p ${_2_5_role_path}/defaults
	mkdir ${_2_5_role_path}/tasks
	cat <<- EOF > ${_2_5_role_path}/defaults/main.yml
	---
	# file: roles/2_5__set_ntp/defaults/main.yml
	gather_facts: no
	connection: local
	set_ntp_syntax_1: "clish -c 
	                     'set ntp server primary {{ item.value.ntp1 }} 
	                      version {{ item.value.ntp1_ver }}' -s
	                      && clish -c 
	                      'set ntp active on' -s"
	set_ntp_syntax_2: "clish -c 
	                     'set ntp server primary {{ item.value.ntp1 }} 
	                      version {{ item.value.ntp1_ver }}' -s
	                      && clish -c 
	                      'set ntp server secondary {{ item.value.ntp2 }} 
	                      version {{ item.value.ntp2_ver }}' -s
	                      && clish -c 
	                      'set ntp active on' -s"
	EOF
	cat <<- EOF > ${_2_5_role_path}/tasks/main.yml
	---
	# file: roles/2_5__set_ntp/tasks/main.yml
	- name: "Configure ntp settings"
	  shell: "{{ set_ntp_syntax_1 }}"
	  with_dict: "{{ ntp_config }}"
	  when:
	    - ntp_config.ntp.ntp1 is defined
	    - ntp_config.ntp.ntp2 is not defined

	- name: "Configure ntp settings"
	  shell: "{{ set_ntp_syntax_2 }}"
	  with_dict: "{{ ntp_config }}"
	  when:
	    - ntp_config.ntp.ntp1 is defined
	    - ntp_config.ntp.ntp2 is defined
	EOF
	#
	# 2_6__gateway_ftw
	#
	echo "         2_6__gateway_ftw"
	_2_6_role_path="${_role_path}/2_6__gateway_ftw"
	if [[ -d ${_2_6_role_path} ]]; then
	    rm -rf ${_2_6_role_path}
	fi
	mkdir -p ${_2_6_role_path}/defaults
	mkdir ${_2_6_role_path}/tasks
	cat <<- EOF > ${_2_6_role_path}/defaults/main.yml
	---
	# file: roles/2_6__gateway_ftw/defaults/main.yml
	gather_facts: no
	connection: local
	EOF
	cat <<- EOF > ${_2_6_role_path}/tasks/main.yml
	---
	# file: roles/2_6__gateway_ftw/tasks/main.yml
	- name: "Create config_system on the gateway"
	  raw: echo "config_system --config-string \"hostname={{ hostname }}
	         &ftw_sic_key={{ sickey }}&timezone='{{ timezone }}'
	         &install_security_managment=false&install_mgmt_primary=false
	         &install_security_gw=true&gateway_daip=false
	         &install_ppak=true&gateway_cluster_member=false
	         &download_info=true\" >> ftw.output & " > /home/admin/ftwstart

	- name: "Change permissions"
	  raw: chmod 755 ftwstart 

	- name: "Run the FTW Setup"
	  command: "/bin/bash /home/admin/ftwstart" 

	- name: Wait until the FTW completes
	  wait_for:
	    path: /etc/.wizard_accepted 
	  register: exists
	  until: exists is success
	  retries: 20
	  delay: 15

	- name: Waiting for 10 seconds before reboot
	  pause:
	    seconds: 10

	- name: Rebooting 
	  command: "shutdown -r now"

	EOF
	#
	# 2_7__set_static_route
	#
	echo "         2_7__set_static_route"
	_2_7_role_path=" ${_role_path}/2_7__set_static_route"
	if [[ -d${_2_7_role_path} ]]; then
	    rm -rf${_2_7_role_path}
	fi
	mkdir -p${_2_7_role_path}/defaults
	mkdir${_2_7_role_path}/tasks
	cat <<- EOF > ${_2_7_role_path}/defaults/main.yml
	---
	# file: roles/2_7__set_static_route/defaults/main.yml
	gather_facts: no
	connection: local
	set_static_route_syntax_1: "clish -c 
	                              'set static-route {{ item.value.dst }} 
	                              nexthop gateway logical 
	                              {{ item.value.interface }} 
	                              {{ item.value.state }} 
	                              priority {{ item.value.priority }}' -s"
	set_static_route_syntax_2: "clish -c 
	                              'set static-route {{ item.value.dst }} 
	                              nexthop gateway address 
	                              {{ item.value.next_hop_address }} 
	                              {{ item.value.state }} 
	                              priority {{ item.value.priority }}' -s"
	EOF
	cat <<- EOF > ${_2_7_role_path}/tasks/main.yml
	---
	# file: roles/2_7__set_static_route/tasks/main.yml
	- name: "Setting static-route"
	  shell: "{{ set_static_route_syntax_1 }}"
	  with_dict: "{{ static_route_config }}"
	  when:
	    - static_route_config.value.interface is defined
	    - static_route_config.value.next_hop_address is not defined

	- name: "Setting static-route"
	  shell: "{{ set_static_route_syntax_2 }}"
	  with_dict: "{{ static_route_config }}"
	  when:
	    - static_route_config.value.next_hop_address is defined
	    - static_route_config.value.interface is not defined
	EOF
	declare -i i; i+=1
	#
	# Creating 0-apistatus.yml playbook for testing purposes
	#
	echo
	echo "+++ ($i) creating '0-apistatus.yml' as the first check point \
playbook ...."
	echo
	cat <<- EOF > ${_chkp_project_path}/0-apistatus.yml 
	---
	# file: 0-apistatus.yml
	- hosts: chkp_sms
	  gather_facts: no
	  tasks:
	    - name: Check API status
	      shell: "$COMMAND"
	      register: api_status
	    - debug:
	         msg: "{{ api_status }}"
	EOF
	declare -i i; i+=1

fi


#--------------------------------------------------------------------
# Setting ownership of the project directory 
# 
echo
echo "||| (-) making '${_project_owner}' the owner of the ansible \
project directory ...."
echo
chown -R ${_project_owner}: ${_project_path}
chmod -R u+w ${_project_path}


#--------------------------------------------------------------------
# Printing the summary 
# 
_msg_header="    ---------------------------------"
_msg_header+="--------------------------------    "
_msg_body_I="The sample Ansible project directory "
_msg_body_I+="has been successfully created.  "
_msg_body_I+="The next step is to create and run your playbooks."
_msg_body_II="    PROJECT OWNER : '${_project_owner}'"
_msg_body_III="     PROJECT PATH : '${_chkp_project_path}'"

echo "${_msg_header}"
echo "${_msg_body_I}"  | fold -s -w 65 | sed -e "s|^|\t|g"
echo "${_msg_body_II}" | sed -e "s|^|\t|g"
echo "${_msg_body_III}"| fold -s -w 65 | sed -e "s|^|\t|g"
echo "${_msg_header}"
echo


#--------------------------------------------------------------------
# Logging in to ${_project_owner} 
# 
su - ${_project_owner}

exit 0

# END
