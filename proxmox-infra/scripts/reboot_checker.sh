#!/bin/bash

# Need to have needs-restarting installed on the system
# dnf install needs-restarting

if ! needs-restarting -r >/dev/null 2>&1; then
    echo "$(date): Reboot required, initiating reboot"
    logger "dnf-automatic: Rebooting system due to updates requiring restart"
    /usr/bin/systemctl reboot
else
    echo "$(date): No reboot required"
fi