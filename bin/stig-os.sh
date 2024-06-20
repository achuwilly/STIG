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
##### Prompt for Manual or Automatic STIG (may excludes some).
unset RESPONSE ANSWER
echo "################################################################################"
echo " Please select how you would like the prompts to run: "
#echo "     Yes - automatically makes any STIG required changes"
echo "      No - reports, with no changes to the system"
echo "  Manual - prompts user to manually decide on each non-comliant item"
echo " *** NOTE: Some checks may require manual interaction, as a precaution."
echo -n " Please enter N or M, followed by Enter: "; read ANSWER ; RESPONSE=${ANSWER^} < /dev/tty
until [[ "$RESPONSE" == 'Y'* ]] || [[ "$RESPONSE" == 'N'* ]] || [[ "$RESPONSE" == 'M'* ]]; do
    echo "That was not a valid SELECTION. Press Y, N, or M, and Enter to continue"; read ANSWER ; RESPONSE=${ANSWER^} < /dev/tty
done
if [[ "$RESPONSE" == 'Y'* ]] ; then RESPONSE='M' ; fi
echo "STIG=$RESPONSE" > /opt/stigs/var/stig.info
chmod 664 /opt/stigs/var/stig.info
source /opt/stigs/var/stig.info
##### Prompt to Backup
if [[ "$STIG" != "N" ]]; then
    unset RESPONSE ANSWER
    echo " You may want to backup vital config files, prior to the STIG process."
    echo -n " Would you like to do so now (Y/N): "; read ANSWER ; RESPONSE=${ANSWER^}
    until [[ "$RESPONSE" == 'Y'* ]] || [[ "$RESPONSE" == 'N'* ]] ; do
        echo -n " --- That was not a valid selection. Press Y or N and Enter to continue: "; read ANSWER ; RESPONSE=${ANSWER^}
    done
    if [[ "$RESPONSE" == 'Y'* ]] ; then
        bash /opt/stigs/modules/"$OS_SHRTNM"/configs-backup.sh
    else
        echo " Ok, but don't say we didn't warn you..." ; sleep 1
    fi
fi
##### Start OS STIG
bash /opt/stigs/modules/"$OS_SHRTNM"/stig-"$OS_SHRTNM".sh
sed -i "s|OS_STIG=.*|OS_STIG='$(date +"%m-%d-%y_%T")'|" /opt/stigs/var/sys-var.sh
echo " "
echo " Your completed checklist can be found in the '/root/reports' directory."
sleep 2 # Wait 2 seconds before continuing.
##### END
