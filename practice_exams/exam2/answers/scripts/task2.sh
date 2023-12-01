#!/bin/bash

ansible all -m copy -a 'src=/home/ansible/exam-files/scripts/get-server-info.sh dest=/usr/local/bin/get-server-info.sh mode=0755 owner=root group=root' -b 

ansible all -a '/usr/local/bin/get-server-info.sh' -b
