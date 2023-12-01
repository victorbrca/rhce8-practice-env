

## Task 4

+ [ ] Using RHEL system roles, create the playbook `playbooks/configure-storage.yml` that configures the following storage on the 'webserver' group:
  + Creates a VG on '/dev/sdb' named 'web_cache_vg'
  + Creates a LV name 'web_cache_lv' using 'web_cache_vg'
  + Formats the LV using XFS
  + Mounts it to '/data/web_cache'

