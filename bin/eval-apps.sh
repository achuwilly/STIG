#!/bin/bash
if [[ ! -e /opt/stigs/var/sys-var.sh ]]; then
    source /opt/stigs/bin/sys-check.sh
    build_hardware_var ; build_os_var ; build_network_var ; local_env_var
fi ; source /opt/stigs/var/sys-var.sh
if [ ! -f /opt/stigs/modules/"$OS_SHRTNM"/stig-"$OS_SHRTNM".sh ]; then
    echo " - - - The $OS_SHRTNM STIG module was not found."
    sleep 2 ; exit 2
fi ; clear
##### Inform of Session Timeout possibility
echo "################################################################################"
echo " Warning:  Some sessions may take longer than average, depending on the size of"
echo " your system, or applications installed.  To avoid this, 'Ctrl+C' to exit and "
echo " start a 'screen' or 'tmux' session, before returning to the STIG tool."
echo "################################################################################"
##### Auto-Select 'N' to force 'evaluate only'
echo "STIG=N" > /opt/stigs/var/stig.info
chmod 644 /opt/stigs/var/stig.info
##### Start OS STIG
bash /opt/stigs/modules/"$OS_SHRTNM"/stig-"$OS_SHRTNM".sh
sed -i "s|OS_STIG=.*|OS_STIG='$(date +"%m-%d-%y_%T")'|" /opt/stigs/var/sys-var.sh
echo " "
echo " Your completed checklist can be found in the '/root/reports' directory."
sleep 2 # Wait 2 seconds before continuing.
##### END
