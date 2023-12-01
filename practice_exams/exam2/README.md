# Exam Scenario 2

## Pre-requisites

+ Register for a free Red Hat Developer subscription and register the control node. Set it to the 8.4 release.
+ Uninstall Ansible if installed
+ Remove all EPEL repos
+ Add the 'ansible-2.9-for-rhel-8-x86_64-rpms' repo via subscription manager
+ Add an additional '10GB' disk to 'node4'
+ Increase the memory on 'node4' to '1024M'
+ Alternatively, run the following playbook from the control node

```bash
cd /vagrant/practice_exams/exam2
ansible-playbook prepare-control.yml
```

## Answers

Answers can also be found in the [answers](./answers/README.md) folder. I would advise to only use it as last resort.

## Objectives

The follow top-level objectives are covered on this exam.

1. Be able to perform all tasks expected of a Red Hat Certified System Administrator
2. Understand core components of Ansible
3. Install and configure an Ansible control node
4. Configure Ansible managed nodes
5. Script administration tasks
6. Create and use static inventories to define groups of hosts
7. Create Ansible plays and playbooks
8. Use Ansible modules for system administration tasks that work with:
9. Create and use templates to create customized configuration files
10. Work with Ansible variables and facts
11. Create and work with roles
12. Download roles from an Ansible Galaxy and use them
13. Use Ansible Vault in playbooks to protect sensitive data
14. Use provided documentation to look up specific information about Ansible modules and commands

## Task 1

Objectives covered:

+ 2. Understand core components of Ansible
+ 3. Install and configure an Ansible control node
+ 4. Configure Ansible managed nodes

Tasks:

+ [ ] Install ansible on the control node
+ [ ] Create a user called 'ansible' on the control node
+ Create the directory `/home/ansible/exam-files`. This is where all files will be saved
  + [ ] Create the following sub-directories:
    + roles, vars, playbooks, scripts, files
  + [ ] Create an ssh key for the 'ansible' user in this folder
+ [ ] Create an inventory file with the nodes:
  + node1
  + node2
  + node3
  + node4
+ Create an ansible config file as follows:
  + [ ] Roles path is set to `/home/ansible/exam-files/roles`
  + [ ] Inventory file is `/home/ansible/exam-files/inventory`
  + [ ] User to SSH to remote nodes is 'ansible'
  + [ ] Add the ssh key from the previous task
  + Disable:
    + [ ] Cow output
    + [ ] Retry files
    + [ ] Host key checking
+ [ ] SSH to all nodes and create the 'ansible' user. Give it a password
+ [ ] Make so that the 'ansible' user can elevate privileges without a password on all nodes
+ [ ] Distribute the ssh key created to the nodes (use any method)
+ [ ] Disable ssh password authentication for the 'ansible' user on all nodes
+ [ ] Create the ad-hoc script `/home/ansible/exam-files/scripts/check-connection.sh` that checks that the ssh connection works to all nodes

## Task 2

Objectives covered:

+ 5. Script administration tasks

Tasks:

+ [ ] Create the shell script `/home/ansible/exam-files/scripts/get-server-info.sh` that:
  + Gets the hostname, OS name, OS version, tuned service status, and the tuned profile that is currently active. Output should look like:

    ```
    Hostname: control.ansi.example.com
    Name: "Red Hat Enterprise Linux"
    Version: "8.0 (Ootpa)"
    Tuned status: active
    Current active profile: virtual-guest
    ```

+ [ ] Create the ad-hoc script `/home/ansible/exam-files/scripts/task2.sh` that:
  + Uploads 'get-server-info.sh' to 'node1' with:
    + To `/usr/local/bin/get-server-info.sh`
    + Owned by 'root:root'
    + Permission is 'rwxr-xr-x'
  + Runs the add-hoc script

## Task 3

Objectives covered:

+ 6. Create and use static inventories to define groups of hosts

Tasks:

+ [ ] Modify the inventory file to have the following groups
  + 'node1' and 'node2' are in the 'webservers' group
  + 'node3' and 'node4' are in the 'databases' group
  + 'node3' is in the 'mysql' group
  + 'node4' is in the 'postgresql' group
  + 'node1' is in the 'version1' group
  + 'node2' is in the 'version2' group

## Task 4

Objectives covered:

+ 7. Create Ansible plays and playbooks

Tasks:

+ [ ] Create the playbook `/home/ansible/exam-files/playbooks/task4.yml`that:
  + Creates the folder `/data/backup` on the 'webservers' group. The folder should have read and execute permission for group and others
  + Creates the file `/etc/server_role` on all servers
    + The content of the file should be 'webservers' or 'databases' according to the inventory group
  + Create a task that uses the `rpm` command to check if 'httpd' is installed on the webservers and databases groups
    + This task should only show as changed when it fails
  + Ceate two tasks that display the following output based on the exit code from the `rpm` task. These tasks should run against the same groups as the `rpm` task:
    + 'HTTPD is installed' if it's installed
    + 'HTTPD is not installed' if it's not installed
  + Makes sure that the default system target is set to 'multi-user.target'
    + Should only set the target if not already set
    + Should show change on failure
    + Should ignore errors

## Task 5

Objectives covered:

+ 1. Be able to perform all tasks expected of a Red Hat Certified System Administrator
+ 8. Use Ansible modules for system administration tasks that work with
+ 10. Work with Ansible variables and facts

Tasks:

+ [ ] Create bash a script called `/home/ansible/exam-files/files/root_space_check.sh` that gets the used space percent for root (`/`) and:
  + Logs an info message to journald that looks like `root_space_check.sh[PID]: / usage is within threshold` when usage is below 70%
  + Logs a warning message to journald with `root_space_check.sh[PID]: / usage is above 70% threshold` when usage is above 70%
+ [ ] Create the playbook `/home/ansible/exam-files/playbooks/task5.yml` that
  + Uploads the `root_space_check.sh` script to `/usr/local/bin/` to all servers and set execute bit all accross (ugo)
  + Adds an entry to root's crontab to execute the script every hour on all servers
  + Does the following on the 'webservers' group
    + Installs 'httpd'
    + Enables and starts the 'httpd' service
    + Enables the 'http' and 'httpd' service on firewalld (runtime and permanent)
    + Sets the `Listen` option in `/etc/httpd/conf/httpd.conf` to the internal IP. E.g.: `Listen 192.168.55.201:80`. Use facts variables for the internal IP
    + Whenever `httpd.conf` is changed
      + Make sure that the 'httpd' service is restarted
      + Backs up an archived (zip) version of `httpd.conf` to `/data/backup/httpd.conf-[YYYYMMDD_HHMMSS].zip` (change `[YYYYMMDD_HHMMSS]` to a date string, e.g.: '20231123_2400')
  + Configures storage on the mysql group as follow:
    + PV using /dev/sdb
    + VG named 'databases_vg'
    + LV name 'databases_lv'
    + ext4 filesystem with the volume label of 'DATABASES'
    + Mounted on fstab under `/data/databases`
  + Enables SELinux on the databases group with targeted policy

## Task 6

Objectives covered:

+ 9. Create and use templates to create customized configuration files
+ 10. Work with Ansible variables and facts
+ 11. Create and work with roles

Tasks:

+ Create the role `/home/ansible/exam-files/roles/start-page`
  + [ ] Manually convert the index.html file into a jinja2 template that will set the following values and add it to the start-page role as a template:

```
[HOSTNAME] - Should get the node FQDN value from an ansible fact variable
[VERSION] - Version group from the inventory
[IP ADDRESS] - Should get the node internal IP value from an ansible fact variable
[TIMEZONE] - Should
```

  + [ ] Create the main task for this role to push the template
+ Create the role `/home/ansible/exam-files/roles/journald-persistent`. This role should:
  + [ ] Enable persistent journald with all the required steps
  + [ ] Set the max storage to 100M
  + [ ] Reload the service when changes are made
+ [ ] Create the playbook `/home/ansible/exam-files/playbooks/task6.yml` that applies the 'start-page' role to the 'webservers' group and the 'jounald-persistent' role to all servers

## Task 7

Objectives covered:

10. Work with Ansible variables and facts

Tasks:

+ [ ] Create the a custom fact for the 'webservers' group with the structure below:
  + `app_version` should be based on the version specified in the inventory file

```
"exam": {
    "server_info": {
        "group": "webservers",
        "app_version": "1"
    }
}
```

> [!NOTE]
> This task can be done via a playbook or manually

## Task 8

Objectives covered:

+ 1. Be able to perform all tasks expected of a Red Hat Certified System Administrator
+ 11. Create and work with roles

Tasks:

_**Before you start, remember you should have added a 10GB disk to node4 and increased it's memory to 1024M**_

+ Create the role `/home/ansible/exam-files/roles/postgresql` that does the following:
  + [ ] Creates a VDO on the 10G disk with:
    + VDO name is 'databases_vdo'
    + 20G logical size
    + Deduplication disabled
    + Auto write mode (write policy)
    _**Perform needed VDO steps, as per RHCSA**_
  + [ ] Create a logical volume with:
    + PV using the vdo device
    + VG named 'databases_vg'
    + LV name 'databases_lv'
  + [ ] Format and mount with:
    + ext4 filesystem (using VDO requirements)
    + Mounted on fstab under `/data/databases`
    *Follow vdo mount requirements, as per RHCSA*
  + [ ] Installs the postgresql package group - `@postgresql`
  + [ ] Modifies the value of `Environment=PGDATA=` in the systemd service for 'postgresql.service' to have the value below (_remember the old path and make sure new value is reloaded_)
      `Environment=PGDATA=/data/databases/postgresql_data`
  + [ ] Creates the directory `/data/databases/postgresql_data`
  + [ ] Sets the ownership of `/data/databases/postgresql_data` to `postgres:postgres` with `rwx------`
  + [ ] Initializes the DB with `postgresql-setup --initdb`
    + Should only run during setup
  + [ ] Enables the SELinux boolean `selinuxuser_postgresql_connect_enabled`
  + [ ] Enables and starts the service `postgresql.service`
    + The service should be restarted whenever the systemd unit file for `postgresql.service` is changed
  **See warning below**
  + [ ] Creates the dir `/data/db_troubleshoot`
  + [ ] Sets the ownership of `/data/db_troubleshoot` to `postgres:postgres` with `rwx------`
  + [ ] Creates the group 'pgsqladmin'
  + [ ] Creates the user 'dbadmin' with primary group of 'pgsqladmin'
  + [ ] Adds an ACL that gives the 'pgsqladmin' group full access to `/data/db_troubleshoot`. This should also be the default ACL for new files
+ [ ] Create the playbook `/home/ansible/exam-files/playbooks/deploy-postgresql.yml` that pushes this role to the 'postgresql' group

> [!WARNING]
> The postgresql service will fail to start. You will need to logon to the server and fix the issue. The solution/fix can be done manually, but it needs to be part of the playbook.

> [!TIP]
> While creating the VDO device you may run into the error below:
>
>      fatal: [node4]: FAILED! => {
>          "changed": false,
>          "module_stderr": "Shared connection to node4 closed.\r\n",
>          "module_stdout": "/tmp/ansible_vdo_payload_crp07req/ansible_vdo_payload.zip/ansible/modules/system/vdo.py:330: YAMLLoadWarning: calling yaml.load() without Loader=... is deprecated, as the default Loader is unsafe. Please read https://msg.pyyaml.org/load for full details.\r\n/bin/sh: line 1:  6280 Killed                  /usr/libexec/platform-python /home/ansible/.ansible/tmp/ansible-tmp-1701096243.3300107-7102-276967642935618/AnsiballZ_vdo.py\r\n",
>          "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error",
>          "rc": 137
>      }
> If that's the case, fully remove the vdo device and then apply the patch below. While this is not part of the exam, it's a good skill to aquire.
>
> https://github.com/ansible-collections/community.general/pull/5632/files
>
> You can identify the path for the Ansible code with `ansible --version`. Then browse to the module shown in that commit message and modify the 2x lines. Note that the line number may not match, but should be pretty close.

## Task 9

Objectives covered:

+ 12. Download roles from an Ansible Galaxy and use them
+ 13. Use Ansible Vault in playbooks to protect sensitive data

Tasks:

+ [ ] Using `ansible-galaxy` search for and download the 'mysql' role by 'geerlingguy'
+ [ ] Create a vault password file and add it to `ansible.cfg`
+ [ ] Create the variable file `/home/ansible/exam-files/vars/mysql.yml` and add the following variables:
  + mysql_root_username: root
  + mysql_root_password: sqlrootpassword
+ [ ] Encrypt the variable file with ansible vault
+ [ ] Modify the role so that it:
  + Changes the root credentials
  + Saves the root credentials to `~/.my.rc`
+ [ ] Create the playbook `/home/ansible/exam-files/playbooks/deploy-mysql.yml` that pushes the role to the mysql group

## Task 10

Objectives covered:

14. Use provided documentation to look up specific information about Ansible modules and commands

Tasks:

+ [ ] Create the file `/home/ansible/exam-files/ansible.cfg.template` with a dump of all possible env and config values. For example:

```
ACTION_WARNINGS:
  default: true
  description: [By default Ansible will issue a warning when received from a task
      action (module or action plugin), These warnings can be silenced by adjusting
      this setting to False.]
  env:
  - {name: ANSIBLE_ACTION_WARNINGS}
  ini:
  - {key: action_warnings, section: defaults}
  name: Toggle action warnings
  type: boolean
  version_added: '2.5'
```

+ [ ] Create the file `/home/ansible/exam-files/ansible.cfg.dump` with all the current variables/settings. For example:

```
ACTION_WARNINGS(default) = True
AGNOSTIC_BECOME_PROMPT(default) = True
ALLOW_WORLD_READABLE_TMPFILES(default) = False
ANSIBLE_CONNECTION_PATH(default) = None
ANSIBLE_COW_PATH(default) = None
ANSIBLE_COW_SELECTION(default) = default
ANSIBLE_COW_WHITELIST(default) = ['bud-frogs', 'bunny', 'cheese', 'daemon', 'default', 'dragon', 'elephant-in-snake', '>
ANSIBLE_FORCE_COLOR(default) = False
ANSIBLE_NOCOLOR(default) = False
ANSIBLE_NOCOWS(default) = False
```

+ [ ] Create the file `/home/ansible/exam-files/ansible-modules.txt` with a list of all the Ansible modules available on this system. For example:

```
a10_server                                                    Manage A10 Networks AX/SoftAX/Thunder/vThunder device...
a10_server_axapi3                                             Manage A10 Networks AX/SoftAX/Thunder/vThunder device...
a10_service_group                                             Manage A10 Networks AX/SoftAX/Thunder/vThunder device...
a10_virtual_server                                            Manage A10 Networks AX/SoftAX/Thunder/vThunder device...
aci_aaa_user                                                  Manage AAA users (aaa:User)
aci_aaa_user_certificate                                      Manage AAA user certificates (aaa:UserCert)
aci_access_port_block_to_access_port                          Manage port blocks of Fabric interface policy leaf pr...
aci_access_port_to_interface_policy_leaf_profile              Manage Fabric interface policy leaf profile interface...
aci_access_sub_port_block_to_access_port                      Manage sub port blocks of Fabric interface policy lea...
aci_aep                                                       Manage attachable Access Entity Profile (AEP) objects...
aci_aep_to_domain                                             Bind AEPs to Physical or Virtual Domains (infra:RsDom...
aci_ap                                                        Manage top level Application Profile (AP) objects (fv...
aci_bd                                                        Manage Bridge Domains (BD) objects (fv:BD)
```

+ [ ] Install jinja2 documentation
