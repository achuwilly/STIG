#!/bin/bash
## Created by NSWC Crane ITD Linux Team
## Version: 2022-Q1
##### Required Access Check
test "$(whoami)" != 'root' && ( echo " ***** This script must be run as root ***** " ; exit 1 )
#####
quit_func () {
    source /opt/stigs/bin/ckl-edit.sh
    ckl-cleanup 2>/dev/null  ## Replace Placeholders with special characters
    chmod 660 -R /root/reports 2>/dev/null
    echo " Any Reports created should be located in '/root/reports'."
    echo " Closing the Linux STIG Scripts... Have a nice day!"
    cd $MYPWD ; sleep 1
    exit
}
use_options () {
    echo "  Usage: /opt/stigs/main [-s] [-e]" 1>&2>/dev/null
    echo '    -s    STIG - Presents Menu for manual STIG selection'
    echo '    -e    EVAL - Runs App and OS STIG, with no prompts, outputting CKL'
    echo '          No Option, defaults to EVAL'
    exit 1
}
apply-answers () {
    if [[ -f /root/reports/answers-file ]] ; then
        bash /root/reports/answers-file #2>/dev/null
        echo -e '\n-- Your Answers-File has been applied.\n' ; sleep 1
    else
        echo ' We were unable to find the Answer File "/root/reports/answers-file".'
        echo ' Would you like to copy the Template there now?'
        echo -n "Please enter y-Yes or n-No, followed by Enter: "; read ANSWER ; RESPONSE=${ANSWER^} < /dev/tty
        if [[ "$RESPONSE" == "Y"* ]];then
            cp /opt/stigs/custom/answers-file /root/reports/answers-file
            chmod 750 /root/reports/answers-file
            echo 'Template copy completed.'
            echo 'Please exit and manually enter your Answers before running again.' ; sleep 1
        fi
    fi
}
##### STIG Menu
stig_menu () {
    until [[ "$SELECTION" = "5" ]]; do
        clear
        echo "################################################################################"
        unset SELECTION
        echo " Welcome to the Linux STIG Scripts."
        echo " Please enter the number, followed by enter, to select the option: "
        echo "  1. STIG - Applications"
        echo "  2. STIG - Operating System"
        echo "  3. Apply Answers File"
        echo "  4. Misc. Options"
        echo "  5. EXIT/Quit Script"
        echo -n "  Enter SELECTION: "; read SELECTION
        case $SELECTION in
          1)  bash /opt/stigs/bin/stig-apps.sh ;;
          2)  bash /opt/stigs/bin/stig-os.sh ;;
          3)  apply-answers ;;
          4)  source /opt/stigs/bin/misc-func.sh ; misc-menu ;;
          5)  quit_func ;;
          *)  echo " That was not a valid entry.  Please try again."
        esac
    done
}
##### EVALUATE Only
eval_only () {
    # Evaluate Apps
    bash /opt/stigs/bin/eval-apps.sh
    # Evaluate OS
    bash /opt/stigs/bin/eval-os.sh
    # Prompt for Answer-File
    echo "Would you like to apply an Answer-File now?"
    echo -n "Please enter y-Yes or n-No, followed by Enter: "; read ANSWER ; RESPONSE=${ANSWER^} < /dev/tty
    until [[ "$RESPONSE" == 'Y'* ]] || [[ "$RESPONSE" == 'N'* ]]; do
        echo -n "*** That was not a valid selection. Press Y or N and Enter to continue: "; read ANSWER ; RESPONSE=${ANSWER^}  < /dev/tty
    done
    if [[ "$RESPONSE" == 'Y'* ]]; then apply-answers ; fi
}
##### STARTING
MYPWD=$(pwd)
cd /opt/stigs/

##### Determine System Variables
if [ ! -d /opt/stigs/var ]; then mkdir /opt/stigs/var ; fi
source /opt/stigs/bin/sys-check.sh
build_hardware_var ; build_os_var ; build_network_var ; local_env_var
source /opt/stigs/var/sys-var.sh

##### Error trap and prep
trap quit_func SIGHUP SIGINT SIGTERM
chmod 755 -R /opt/stigs/
chown root:root -R /opt/stigs/
cd /opt/stigs/
if [ ! -d /root/reports ]; then mkdir -p /root/reports ; fi

##### STIG or Evaluate
# Get Options
while getopts 'se' OPTION ; do
    case $OPTION in
        s) stig_menu ;;
        e) eval_only ;;
        *) use_options ;;
    esac
done
if [ $OPTIND -eq 1 ] ; then eval_only ; unset OPTIND ; fi
##### END
