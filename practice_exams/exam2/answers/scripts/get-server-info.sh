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
