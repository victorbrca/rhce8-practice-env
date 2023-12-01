#!/bin/bash

root_usage="$(df --output=pcent / | grep -Eo '[0-9]{1,3}')"
# Another example
# root_usage="$(df -h / | grep -v Filesystem | awk '{print $5}' | tr -d '%')"

if (( root_usage < 70 )) ; then
  logger -p info -t 'root_space_check.sh' "/ usage is below threshold"
elif (( root_usage > 70 )) ; then
  logger -p info -t 'root_space_check.sh' "/ usage is above threshold"
fi
