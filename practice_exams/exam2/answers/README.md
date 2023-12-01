# Exam Scenario 2 Answers

Below are the answers for Exam Scenario 2. You can also find all the files that would need to be created for this scenario on this folder.

## Task 1

### Install Ansible

```bash
useradd ansible
```

```bash
su - ansible
```

```bash
mkdir exam-files
```


	$ ssh-keygen
	Generating public/private rsa key pair.
	Enter file in which to save the key (/home/ansible/.ssh/id_rsa): id_rsa
	Enter passphrase (empty for no passphrase):
	Enter same passphrase again:
	Your identification has been saved in id_rsa.
	Your public key has been saved in id_rsa.pub.
	The key fingerprint is:
	SHA256:rI3irvdNYBw1mUz/heLTAVloIiPfoR1KzJMwU/IC2N4 ansible@rhel8.localdomain
	The key's randomart image is:
	+---[RSA 3072]----+
	| o. ==.++o.+.    |
	|. ...=O.Bo+. .   |
	| . ..+oO =o o .  |
	|  . Eo+oo. + o   |
	|      + S o o    |
	|     . =   .     |
	|    . o o        |
	|   ... o         |
	|  .+o.. .        |
	+----[SHA256]-----+



```bash
mkdir {roles,vars,playbooks,scripts,files}
```

`inventory`

```ini
node1
node2
node3
node4
```

`ansible.cfg`

```ini
[defaults]

inventory 		= ./inventory
roles_path 		= ./roles
remote_user		= ansible
private_key_file 	= ./id_rsa
host_key_checking 	= false
nocows 			= 1
retry_files_enabled 	= false
```

```bash
useradd ansible
passwd ansible
```



```bash
visudo -f /etc/sudoers.d/ansible
```

```sudoers
ansible 	ALL=(ALL)	NOPASSWD: ALL
```

	# su - ansible

	$ sudo -ln
	Matching Defaults entries for ansible on node2:
	    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset,
	    env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS", env_keep+="MAIL PS1 PS2 QTDIR USERNAME
	    LANG LC_ADDRESS LC_CTYPE", env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES",
	    env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE
	    LINGUAS _XKB_CHARSET XAUTHORITY", secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

	User ansible may run the following commands on node2:
	    (ALL) NOPASSWD: ALL


```bash
for i in 1 2 3 4 ; do
  sshpass -p ansible ssh-copy-id -i ./id_rsa.pub ansible@node${i}
done
```


```bash
ssh ansible@node1 -i id_rsa
```

Add to `/etc/ssh/sshd_config`

```config
Match User ansible
	PasswordAuthentication no
```

`scripts/check-connection.sh `

```bash
#!/bin/bash

ansible all -m ping
```

## Task 2

### Script: get-server-info.sh

`scripts/get-server-info.sh`

```
#!/bin/bash

tuned_profile="$(tuned-adm active | grep 'Current active profile')"

if [ ! "$tuned_profile" ] ; then
  tuned_status="inactive"
  tuned_profile=" disabled"
else
  tuned_status="active"
  tuned_profile="$(echo "$tuned_profile" | awk -F':' '{print $2}')"
fi

echo "Hostname: $(hostname)
Name: $(grep -E '^NAME=' /etc/os-release | awk -F"=" '{print $2}')
Version: $(grep -E '^VERSION=' /etc/os-release | awk -F"=" '{print $2}')
Tuned status: $tuned_status
Current active profile:${tuned_profile}"
```

### Script: task2.sh

`scripts/task2.sh`

```bash
#!/bin/bash

ansible all -m copy -a 'src=/home/ansible/exam-files/scripts/get-server-info.sh dest=/usr/local/bin/get-server-info.sh mode=0755 owner=root group=root' -b

ansible all -a '/usr/local/bin/get-server-info.sh' -b
```

## Task 3

```ini
[webservers]
node1
node2

[databases]
node3
node4

[mysql]
node3

[postgresql]
node4

[version1]
node1

[version2]
node2
```

## Task 4


`playbooks/task4.yml`

```yaml
---
- hosts: all
  become: true

  tasks:

    - name: Creates /data/backup
      file:
        path: /data/backup
        state: directory
        mode: g+x,o+x
      when: '"webservers" in group_names'

    - name: Create /etc/server_role
      copy:
        dest: /etc/server_role
        content: "{{ group_names | string | regex_search('webservers|databases')}}"

    - name: Cheks if httpd is installed
      command: rpm -qa | grep -qE '^httpd-[0-9]'
      args:
        warn: false
      register: httpd_install_status
      changed_when: false
      when: '"webservers" in group_names or "databases" in group_names'

    - name: Shows httpd package as installed
      debug:
        msg: "HTTPD is installed"
      when:
        - 'httpd_install_status.rc == 0 and
          ("webservers" in group_names or "databases" in group_names)'

    - name: Shows httpd package as not installed
      debug:
        msg: "HTTPD is not installed"
      when:
        - 'httpd_install_status.rc != 0 and
          ("webservers" in group_names or "databases" in group_names)'

    - name: Makes sure default target is multi-user.target
      shell: |
          if ! systemctl get-default | grep -q multi-user.target ; then
            systemctl set-default multi-user.target
            /bin/false
          else
            exit 0
          fi
      register: targetlevel_output
      changed_when: targetlevel_output.rc == 1
      ignore_errors: true

```

## Task 5

`playbooks/task5.yml`

```yaml
---
- hosts: all
  become: true

  handlers:
    - name: Restat HTTPD
      systemd:
        name: httpd
        state: restarted
      listen: "Restart HTTPD"
      when: '"webservers" in group_names'

    - name: Backup httpd.conf
      archive:
        path: /etc/httpd/conf/httpd.conf
        dest: "/data/backup/http.conf-{{ ansible_date_time.date | replace('-', '') }}_{{ ansible_date_time.time | replace(':', '') }}.zip"
        format: zip
      listen: "Backup httpd.conf"
      when: '"webservers" in group_names'

  tasks:

    - name: Uploads root_space_check.sh
      copy:
        src: /home/ansible/exam-files/files/root_space_check.sh
        dest: /usr/local/bin/root_space_check.sh
        mode: ugo+x

    - name: Adds root_space_check.sh to con
      cron:
        name: Runs root_space_check.sh every hour
        special_time: hourly
        job: /usr/local/bin/root_space_check.sh

    # Block starts
    - name: Block for webservers
      block:

      - name: Installs httpd
        dnf:
          name: httpd

      - name: Enables the httpd service
        systemd:
          name: httpd
          enabled: yes
          state: started

      - name: Opens ports for httpd
        firewalld:
          service: "{{ item }}"
          permanent: yes
          state: enabled
        loop:
          - http
          - https

      - name: Changes the Listen option in /etc/httpd/conf/httpd.conf
        lineinfile:
          path: /etc/httpd/conf/httpd.conf
          line: "Listen {{ ansible_eth1.ipv4.address }}:80"
          regexp: "^Listen .*"
        notify:
          - "Restart HTTPD"
          - "Backup httpd.conf"

      when: '"webservers" in group_names'
    # Block end

    # Block starts
    - name: Start block for databases
      block:

      - name: Creates PV and VG
        lvg:
          vg: databases_vg
          pvs: /dev/sdb

      - name: Create LV
        lvol:
          vg: databases_vg
          lv: databases_lv
          size: 100%FREE
          shrink: false

      - name: Formats to ext4
        filesystem:
          fstype: ext4
          dev: /dev/mapper/databases_vg-databases_lv
          opts: '-L DATABASES'

      - name: Create the mountpoint for DATABASES
        mount:
          path: /data/databases
          src: LABEL=DATABASES
          fstype: ext4
          state: present

      when: '"mysql" in group_names'
    # Block end

    - name: Enables SELinux for databases
      selinux:
        state: enforcing
        policy: targeted
      when: '"databases" in group_names'

```

## Task 6

### Role: start-page

```bash
cd roles
ansible-galaxy init start-page
```

`roles/start-page/templates/index.html.j2`

```jinja2
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Information</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        div {
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <h1>Server Information</h1>

    <div>
        <strong>Hostname:</strong> <span id="hostname">{{ ansible_fqdn }}</span>
    </div>

    <div>
        <strong>Node Group:</strong> <span id="group">{{ group_names | string | regex_search('version.') }}</span>
    </div>

    <div>
        <strong>IP Address:</strong> <span id="ip">{{ ansible_eth1.ipv4.address  }}</span>
    </div>

    <div>
        <strong>Timezone:</strong> <span id="timezone">{{ ansible_date_time.tz }}</span>
    </div>

</body>
</html>
```

`roles/start-page/tasks/main.yml `

```yaml
---
# tasks file for start-page

- name: Pushes index.html
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
```

### Role: journald-persistent

```bash
cd roles
ansible-galaxy init journald-persistent
```

`roles/journald-persistent/tasks/main.yml`

```yaml
---
# tasks file for journald-persistent

- name: Create /var/log/journal
  file:
    path: /var/log/journal
    state: directory
    owner: root
    group: root

- name: Configures /etc/systemd/journald.conf
  lineinfile:
    path: /etc/systemd/journald.conf
    line: "{{ item.line }}"
    regexp: "{{ item.regexp }}"
  loop:
    - { line: 'SystemMaxUse=100M', regexp: '^SystemMaxUse=.*' }
    - { line: 'Storage=persistent', regexp: '^Storage=.*' }
  notify: "Restart Journald"
```

`roles/journald-persistent/handlers/main.yml`

```yaml
---
# handlers file for journald-persistent

- name: Restarts
  systemd:
    name: systemd-journald.service
    state: restarted
  listen: "Restart Journald"
```

### Playbook

`playbooks/task6.yml`

```jinja2
---
- hosts: all
  become: true

  roles:
    - name: start-page
      when: '"webservers" in group_names'

    - name: journald-persistent
```

## Task 7

node1:

	sudo mkdir -p /etc/ansible/facts.d

`/etc/ansible/facts.d/exam.fact`

```ini
[server_info]
group=webservers
app_version=1
```

node2:

	sudo mkdir -p /etc/ansible/facts.d

`/etc/ansible/facts.d/exam.fact`

```ini
[server_info]
group=webservers
app_version=2
```

ansible-console

	ansible@webservers (2)[f:5]$ ls
	node1 | CHANGED | rc=0 >>

	node2 | CHANGED | rc=0 >>

    ansible@webservers (2)[f:5]$ setup

	ansible@webservers (2)[f:5]$ debug var=ansible_local
	node1 | SUCCESS => {
	    "ansible_local": {
	        "exam": {
	            "server_info": {
	                "app_version": "1",
	                "group": "webservers"
	            }
	        }
	    }
	}
	node2 | SUCCESS => {
	    "ansible_local": {
	        "exam": {
	            "server_info": {
	                "app_version": "2",
	                "group": "webservers"
	            }
	        }
	    }
	}

## Task 8

### Role: postgresql

`roles/postgresql/tasks/main.yml`

```yaml
---
# tasks file for postgresql

- name: Installs the VDO package
  dnf:
    name:
      - vdo
      - kmod-kvdo

- name: Starts the VDO service
  systemd:
    name: vdo.service
    state: started
    enabled: true

  # The force option in the vdo module is not present on Ansible 2.9
- name: Checks if VDO volume already exists
  command: vdostats databases_vdo
  register: vgostats_output
  changed_when: false
  ignore_errors: true

- name: Creates the VDO partition
  vdo:
    name: databases_vdo
    device: /dev/sdb
    logicalsize: 20G
    writepolicy: auto
    deduplication: disabled
    #force: false
  when: vgostats_output == 1

- name: Create the volume group
  lvg:
    pvs: /dev/mapper/databases_vdo
    vg: databases_vg

- name: Create the logical volume
  lvol:
    lv: databases_lv
    vg: databases_vg
    size: 100%FREE
    force: false
    shrink: false

- name: Creates the ext4 filesystem
  filesystem:
    dev: /dev/mapper/databases_vg-databases_lv
    fstype: ext4
    opts: -E nodiscard

- name: Mounts the filesystem
  mount:
    fstype: ext4
    opts: defaults,_netdev,discard,x-systemd.requires=vdo.service,x-systemd.device-timeout=0
    src: /dev/mapper/databases_vg-databases_lv
    path: /data/databases
    state: mounted

- name: Installs the postgresql module
  dnf:
    name: '@postgresql'
  register: postgresql_install

- name: Configures the data folder for postgresql service
  lineinfile:
    path: /usr/lib/systemd/system/postgresql.service
    line: 'Environment=PGDATA=/data/databases/postgresql_data'
    regexp: '^Environment=PGDATA=.*'
  notify: "Reload daemon"

- name: Creates /data/databases/postgresql_data
  file:
    path: /data/databases/postgresql_data
    state: directory
    owner: postgres
    group: postgres
    mode: '0700'
  register: create_postgresql_data

- name: Initializes the DB
  command: postgresql-setup --initdb
  args:
    creates: /data/databases/postgresql_data/PG_VERSION
  when:
    - postgresql_install.changed == true
    - postgresql_data.changed == true

- name: Installs semanage
  dnf:
    name: setroubleshoot-server

- name: Enables the selinuxuser_postgresql_connect_enabled boolean
  seboolean:
    name: selinuxuser_postgresql_connect_enabled
    state: yes
    persistent: yes

- name: Fixes the SELinux context for the postgresql data files
  sefcontext:
    target: '/data/databases(/.*)?'
    setype: postgresql_db_t
    state: present
  notify: "Restore SELinux context"
```

`roles/postgresql/handlers/main.yml`

```yaml
---
# handlers file for postgresql

- name: Reload daemon
  systemd:
    name: postgresql.service
    daemon_reload: true
    enabled: true
  listen: "Reload daemon"

- name: Restore SELinux context
  command: restorecon -irv /data/databases
  when: change_selinux_context.changed == true
  listen: "Restore SELinux context"
  notify: "Restart postgresql service"

- name: Restart postgresql.service
  systemd:
    name: postgresql.service
    state: restarted
  listen: "Restart postgresql service"
```

### Playbook

`playbooks/deploy-postgresql.yml`

```yaml
---
- hosts: postgresql
  become: true

  roles:
    - postgresql

  tasks:
    - name: Checks if /data/db_troubleshoot exists
      stat:
        path: /data/db_troubleshoot
      register: stat_db_troubleshoot

    - name: Creates /data/db_troubleshoot
      file:
        path: /data/db_troubleshoot
        state: directory
        owner: postgres
        group: postgres
        mode: '0700'
        force: false
      when: stat_db_troubleshoot.stat.exists == false

    - name: Creates the group pgsqladmin
      group:
        name: pgsqladmin

    - name: Creates the user dbadmin
      user:
        name: dbadmin
        group: pgsqladmin

    - name: Sets default ACL for /data/db_troubleshoot
      acl:
        path: /data/db_troubleshoot
        default: true
        etype: group
        entity: pgsqladmin
        permissions: rwx
        state: present

    - name: Sets ACL for /data/db_troubleshoot
      acl:
        path: /data/db_troubleshoot
        etype: group
        entity: pgsqladmin
        permissions: rwx
        state: present
```

## Task 9

### Download Role

	$ ansible-galaxy role install geerlingguy.mysql
	- downloading role 'mysql', owned by geerlingguy
	- downloading role from https://github.com/geerlingguy/ansible-role-mysql/archive/4.3.3.tar.gz
	- extracting geerlingguy.mysql to /home/ansible/exam-files/roles/geerlingguy.mysql
	- geerlingguy.mysql (4.3.3) was installed successfully

###

```bash
$ tr -dc A-Za-z0-9*_$^! < /dev/urandom | head -c 24 > .vault_passwd
```

```ini
[defaults]

inventory 		= ./inventory
roles_path 		= ./roles
remote_user		= ansible
private_key_file 	= ./id_rsa
host_key_checking 	= false
nocows 			= 1
retry_files_enabled 	= false
vault_password_file     = ./.vault_passwd
```

`vars/mysql.yml`

```yaml
---
mysql_root_username: root
mysql_root_password: sqlrootpassword
```

	$ ansible-vault encrypt vars/mysql.yml
	Encryption successful

Change the line below in `roles/geerlingguy.mysql/defaults/main.yml`

```yaml
mysql_root_password_update: true
```

`playbooks/deploy-mysql.yml`

```yaml
---
- hosts: mysql
  become: true

  vars_files:
    - /home/ansible/exam-files/vars/mysql.yml

  roles:
    - geerlingguy.mysql
```

## Task 10

###

	ansible-config list > ansible.cfg.template

	ansible-config dump > ansible.cfg.dump

	ansible-doc -l > ansible-modules.txt

### Install jinja2 documentation

	dnf install -y python3-jinja2.noarch

Documentation files can be found with:

	rpm -ql python3-jinja2.noarch | grep index.html
	/usr/share/doc/python3-jinja2/examples/rwbench/django/index.html
	/usr/share/doc/python3-jinja2/examples/rwbench/genshi/index.html
	/usr/share/doc/python3-jinja2/examples/rwbench/jinja/index.html
	/usr/share/doc/python3-jinja2/examples/rwbench/mako/index.html
	/usr/share/doc/python3-jinja2/ext/django2jinja/templates/index.html
	/usr/share/doc/python3-jinja2/html/genindex.html
	/usr/share/doc/python3-jinja2/html/index.html
	/usr/share/doc/python3-jinja2/html/latexindex.html
	/usr/share/doc/python3-jinja2/html/py-modindex.html

