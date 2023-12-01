# Exam Scenario 3 Answers

Below are the answers for Exam Scenario 3.


## Task 1

	mkdir {inventories,playbooks,roles,files,templates}


`ansible.cfg `

```ini
[defaults]
remote_user = vagrant
roles_path = ./roles
inventory = ./inventories/lab_inventory.ini
ask_pass = true

[privilege_escalation]
become = true
become_ask_pass = false
become_method = sudo
become_user = root
```

`inventories/lab_inventory.ini` 

```ini
[repo]
repo.ansi.example.com

[control]
control.ansi.example.com ansible_connection=local

[dv]
node1.ansi.example.com
node3.ansi.example.com

[qa]
node2.ansi.example.com
node4.ansi.example.com

[webserver]
node[1:3].ansi.example.com

[sqlserver]
node4.ansi.example.com
```

## Task 2

	sudo dnf install -y rhel-system-roles

```ini
roles_path = ./roles:/usr/share/ansible/roles
```

`playbooks/setup-ssh.yml`

```yaml
---
- hosts: control 
  become: true

  tasks:
  - name: "Configure ssh clients"
    include_role:
      name: rhel-system-roles.ssh
    vars:
      ssh_user: vagrant
      ssh:
        StrictHostKeyChecking: no
```

## Task 3

`playbooks/kernel-parameters.yml` 

```yaml
---
- hosts: dv
  become: true

  vars:
    kernel_settings_sysctl:
      - name: fs.file-max
        value: 400000
      - name: kernel.threads-max
        value: 65536
  roles:
    - rhel-system-roles.kernel_settings
```
