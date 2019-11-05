# cp-ansible-pipeline
This is a pipeline to create a sample ansible project directory for the
deployment of a Check Point gateway as well as its decommissioning.

In order to create a fully functional sample project directory, 
you should run the following commands.
```
$ sudo bash 0_cpap_pkg_installer.sh
$ sudo bash 1_cpap_directory_builder.sh -G -V -C -m
$ bash 2_cpap_sample_builder.sh
```
The created project directory would contain the required inventory, 
roles, libraries, var files, and playbooks. After the project directory 
is ready, you can run the playbooks using
```
$ ansible-playbook PLAYBOOK_FILE_PATH -i INVENTORY_FILE_PATH
  --vault-id VAULT_ID_LABEL@$VAULT_ID_SOURCE
```
Example syntaxes for the [sample project](sample/ansible_dev_local/checkpoint)
can be found in section 2.1 of `2_cpap_sample_builder.sh -i`.

A pipeline approach is generally useful in situations where we are
dealing with multiple environments with shared infrastructure and
shared targets of automation and specifically for environments which
require planned commission and decommission at the same time.


## Modifying the existing pipeline
A comprehensive documentation of the structure and files within the
sample project directory can be found in `2_cpap_sample_builder.sh
-i`. Furthermore, all the playbooks and var files contain brief
explanations of what they contain and what they do at their
preamble.

We briefly go over some of the modifications that can be made.
- **Roles**: you can either modify  
  - [1_cpap_directory_builder.sh](1_cpap_directory_builder.sh) OR
  - the files within [sample/ansible_dev_local/checkpoint/roles](sample/ansible_dev_local/checkpoint/roles)

- **Inventory**: you can either modify
  - the \*Creating the inventory\* section of [2_cpap_sample_builder.sh](2_cpap_sample_builder.sh) OR
  - [dev1_chkp](sample/ansible_dev_local/checkpoint/dev1_chkp) and files within
    - [sample/ansible_dev_local/checkpoint/host_vars](sample/ansible_dev_local/checkpoint/host_vars)
    - [sample/ansible_dev_local/checkpoint/group_vars](sample/ansible_dev_local/checkpoint/group_vars)

    **NOTE:** some of the inventory variables are ansible-vault encrypted.

- **Scripts**: you can either modify
  - the \*Creating scripts ...\* section of [2_cpap_sample_builder.sh](2_cpap_sample_builder.sh) OR
  - the files within [sample/ansible_dev_local/checkpoint/scripts/gaia](sample/ansible_dev_local/checkpoint/scripts/gaia)

- **Variables**: you can either modify
  - the \*Creating VMware and Check Point vars\* section of [2_cpap_sample_builder.sh](2_cpap_sample_builder.sh) OR
  - the files within 
    - [sample/ansible_dev_local/checkpoint/vmware_vars](sample/ansible_dev_local/checkpoint/vmware_vars)
    - [sample/ansible_dev_local/checkpoint/checkpoint_vars](sample/ansible_dev_local/checkpoint/checkpoint_vars)

- **Library**: you can add your own ansible modules or modify the existing ones inside 
  - [sample/ansible_dev_local/checkpoint/library](sample/ansible_dev_local/checkpoint/library) OR
  - modify [0_cpap_pkg_installer.sh](0_cpap_pkg_installer.sh)
  
  *Gateway VM Deployment*
  - your vm template
  - [sample/ansible_dev_local/checkpoint/roles/1_1__vmware_guest_clone](sample/ansible_dev_local/checkpoint/roles/1_1__vmware_guest_clone)
  - [dev1_vcsa_clone_vars.yml](sample/ansible_dev_local/checkpoint/vmware_vars/dev1_vcsa_clone_vars.yml)
  - [1__dev1_create_api.yml](sample/ansible_dev_local/checkpoint/1__dev1_create_api.yml) or 
    [1__dev1_create_bash.yml](sample/ansible_dev_local/checkpoint/1__dev1_create_bash.yml)
  
  *Gateway Gaia Configuration*
  - 2_X__Y roles in [sample/ansible_dev_local/checkpoint/roles](sample/ansible_dev_local/checkpoint/roles)
  - [dev1_gaia_config_vars.yml](sample/ansible_dev_local/checkpoint/checkpoint_vars/dev1_gaia_config_vars.yml)
  - [1__dev1_create_api.yml](sample/ansible_dev_local/checkpoint/1__dev1_create_api.yml) or 
    [1__dev1_create_bash.yml](sample/ansible_dev_local/checkpoint/1__dev1_create_bash.yml)

  *Security Policy Provisioning*
  - Engaging remote api calls
    - [dev1_policy_pkg_vars.yml](sample/ansible_dev_local/checkpoint/checkpoint_vars/dev1_policy_pkg_vars.yml)
    - [__dev1_create_checkpoint_gw_api.yml](sample/ansible_dev_local/checkpoint/sub_chkp/__dev1_create_checkpoint_gw_api.yml)
    - [__dev1_create_policy_package_api.yml](sample/ansible_dev_local/checkpoint/sub_chkp/__dev1_create_policy_package_api.yml)
    - [1__dev1_create_api.yml](sample/ansible_dev_local/checkpoint/1__dev1_create_api.yml)
  - Taking advantage of bash
    - csv files in [sample/ansible_dev_local/checkpoint/scripts/gaia](sample/ansible_dev_local/checkpoint/scripts/gaia)
    - [dev1_create_chkp_gw.sh](sample/ansible_dev_local/checkpoint/scripts/gaia/dev1_create_chkp_gw.sh)
    - [dev1_create_policy_package.sh](sample/ansible_dev_local/checkpoint/scripts/gaia/dev1_create_policy_package.sh)
    - [__dev1_create_checkpoint_gw_bash.yml](sample/ansible_dev_local/checkpoint/sub_chkp/__dev1_create_checkpoint_gw_bash.yml)
    - [__dev1_create_policy_package_bash.yml](sample/ansible_dev_local/checkpoint/sub_chkp/__dev1_create_policy_package_bash.yml)
    - [1__dev1_create_bash.yml](sample/ansible_dev_local/checkpoint/1__dev1_create_bash.yml)

  *Gateway Decommissioning*
  - csv files in [sample/ansible_dev_local/checkpoint/scripts/gaia](sample/ansible_dev_local/checkpoint/scripts/gaia)
  - [dev1_chkp_revert.sh](sample/ansible_dev_local/checkpoint/scripts/gaia/dev1_chkp_revert.sh)
  - [sample/ansible_dev_local/checkpoint/roles/1_3__vmware_guest_revert_gw_only](sample/ansible_dev_local/checkpoint/roles/1_3__vmware_guest_revert_gw_only)
  - [2__dev1_revert_clean.yml](sample/ansible_dev_local/checkpoint/2__dev1_revert_clean.yml)

---
## Copyright information
This project is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This project is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this project.  If not, see [https://www.gnu.org/licenses](https://www.gnu.org/licenses).

The [cpAnsible](https://github.com/CheckPointSW/cpAnsible) module deployed in 
[sample/ansible_dev_local/checkpoint/library](sample/ansible_dev_local/checkpoint/library)
is licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the Apache License, Version 2 has been placed in [sample/ansible_dev_local/checkpoint/library](sample/ansible_dev_local/checkpoint/library).
