# Exam Scenario 3

This exam scenario concentrates on using RHEL System Roles.

## Pre-requisites

+ Register for a free Red Hat Developer subscription and register the control node. Set it to the 8.4 release.

```bash
cd /vagrant/practice_exams/exam3
ansible-playbook prepare-control.yml
```

## Answers

Answers can also be found in the [answers](./answers/README.md) folder. I would advise to only use it as last resort.

## Objectives

## Task 1

+ [ ] Create the following file structure under the vagrant user's home on the control node
```ini
ansible/
|-- ansible.cfg
|-- inventories/
|   `-- lab_inventory.ini
|-- playbooks/
|-- roles/
|-- files/
`-- templates/
```
+ Configure the following options in `ansible.cfg`:
  + [ ] Default ssh user is vagrant
  + [ ] Privilege escalation 
    + Enabled by default
    + User set to root
    + Method to use is 'sudo'
    + Do not ask for password
  + [ ] Roles path is set to `./roles`
  + [ ] Inventory is set to `./inventories/lab_inventory.ini`
  + [ ] Prompt for connection password
+ [ ] Configure the inventory file with the following:
  + 'control' is part of the 'control' group and is set to use local connection
  + 'repo' is part of the 'repo' group
  + 'dv' group contains 'node1' and 'node3'
  + 'qa' group contains 'node2' and 'node4'
  + 'webserver' group contains 'node1', 'node2' and 'node3'. **Use only one line to list the nodes under this group**
  + 'sqlserver' group contains 'node4'

## Task 2

+ [ ] Setup the control node so that the RHEL systems roles are available
+ [ ] Add the RHEL systems roles to `ansible.cfg`
+ [ ] Create the playbook `playbooks/configure-ssh-config.yml` using RHEL systems roles that sets the following configuration for the 'vagrant' user in the control node:
  + Disables strict host checking

## Task 3

+ [ ] Using RHEL system roles, create the playbook `playbooks/kernel-parameters.yml` that configures the following kernel parameters on the 'dv' group:
  + fs.file-max = 400000
  + kernel.threads-max = 65536
