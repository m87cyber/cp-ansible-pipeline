#!/bin/bash
#
#--------------------------------------------------------------------
#
#         NAME:   0_cpap_pkg_installer.sh
#
#        USAGE:   bash 0_cpap_pkg_installer.sh [-h] [-v] [-a] 
#                                              [-i PYPKG]
#
#  DESCRIPTION:   Basic installation of Ansible and Terraform without
#                 any modification of the default configuration.
#
# REQUIREMENTS:   Ubuntu Server 16.04
#                 root permission
#        NOTES:   'simplejson', 'netaddr', 'boto', 'boto3',
#                 'cryptography', and 'PyVmomi' python packages will
#                 be installed by default.
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
	Usage: $0 [-h] [-v] [-a] [-i PYPKG]
	       $0
	Example: $0 -a -i 'bar'

	Description:
	Install Ansible and/or Terraform with default configuration from 
	apt repositories.
	By default, 'simplejson', 'netaddr', 'boto', 'boto3', 'cryptography', 
	and 'PyVmomi' python packages would be installed during execution.
	If required, a list of additional python packages to be installed 
	using pip can be given inside quotes/double-quotes as the '-i' argument. 

	Options:
	   -h, --help          display this help text and exit
	   -v, --version       display version information and exit
	   -a, --ansible-only  install ansible only
	   -i, --add-pypkg     install additional python packages using pip

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
SCRIPT_NAME="cpap - pkg installer"
SCRIPT_VERSION="0.2"
SCRIPT_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SCRIPT_POSITIONAL=()
TERRAFORM_VER="$(curl -s https://releases.hashicorp.com/terraform/ \
	            | grep -vE "<li>|</li>|<ul>|</ul>|-beta|alpha" \
	            | grep "<a href=\"" \
	            | cut -d ">" -f 2 \
	            | sed 's/<\/a//' \
	            | grep "../" -A 1 \
	            | grep -v '../' \
	            | cut -c 11-)"
TERRAFORM_URL="https://releases.hashicorp.com"
TERRAFORM_URL+="/terraform/${TERRAFORM_VER}"
TERRAFORM_URL+="/terraform_${TERRAFORM_VER}_linux_amd64.zip"
if [[ ! -z "${TERRAFORM_VER}" ]]; then
   TERRAFORM_INSTALL="yes"
fi


#--------------------------------------------------------------------
# Checking the requirements
#
if [[ -z "$(lsb_release -sd | grep "Ubuntu 16.04")" ]]; then
	_err "This is not 'Ubuntu 16.04'."
fi
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
	    -a|--ansible-only)
	        TERRAFORM_INSTALL="no"
	        shift           # jump over the flag 
	        ;;
	    -i|--add-pypkg)
	        PY_PKGS="$2"
	        shift           # jump over the flag
	        shift           # jump over the value
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
echo "     INSTALL TERRAFORM : ${TERRAFORM_INSTALL}"
echo "ADDITIONAL PYTHON PKGS : ${PY_PKGS}"
echo;echo
echo 'Press enter to continue ...'
read


#--------------------------------------------------------------------
# Installing packages and modules
#
echo;echo
echo "+----------------------------------------------------------+"
echo "|             Installing the required packages             |"
echo "+----------------------------------------------------------+"
echo
echo "||| (I) Upgrading $(lsb_release -sd) $(lsb_release -sc) ..."
echo
apt-get update; apt-get dist-upgrade
echo
echo "||| (II) Installing software-properties-common ..."
echo
apt-get install software-properties-common
echo
echo "||| (III) Installing Ansible ..."
echo
apt-add-repository ppa:ansible/ansible 
apt-get update 
apt-get install ansible
echo
echo "||| (IV) Installing pip, simplejson, netaddr, boto, and boto3 ..."
echo
apt-get install python-pip 
$(which pip) install --upgrade pip
$(which pip) install simplejson 
$(which pip) install netaddr 
$(which pip) install boto 
$(which pip) install boto3 
$(which pip) install cryptography 
$(which pip) install PyVmomi 
if [[ ! -z "${PY_PKGS}" ]]; then
	for item in "${PY_PKGS}"; do
	    $(which pip) install ${item}
	done
fi
echo
echo "** ******************************************************* **"
echo "    Ansible is installed with the following configuration     "
echo "   -------------------------------------------------------   "
echo "$(ansible --version )" | fold -s -w 55 | sed -e "s|^|   |g"
echo "** ******************************************************* **"

if [[ ${TERRAFORM_INSTALL}  == "yes" ]]; then
	echo
	echo "||| (V) Installing Terraform ..."
	echo
	apt-get install git 
	apt-get install wget unzip 
	wget ${TERRAFORM_URL}
	unzip terraform_${TERRAFORM_VER}_linux_amd64.zip 
	mv terraform /usr/local/bin/ 
	rm -rfv terraform* 
	which terraform
	echo
	echo "** ******************************************************* **"
	echo "   Terraform version ${TERRAFORM_VER} is installed."
	echo "** ******************************************************* **"
	echo
else
	echo
	echo "-------------------- WARNING --------------------------"
	echo "Check your connectivity to"
	echo "https://releases.hashicorp.com/terraform"
	echo "  You need to manually download and install Terraform  "
	echo "-------------------------------------------------------"
	echo
fi

exit 0

# END
