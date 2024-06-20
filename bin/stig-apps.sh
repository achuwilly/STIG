#!/bin/bash
if [[ ! -e /opt/stigs/var/sys-var.sh ]]; then
    source /opt/stigs/bin/sys-check.sh
    build_hardware_var ; build_os_var ; build_network_var ; local_env_var
fi
source /opt/stigs/var/sys-var.sh
source /etc/os-release
##### Firefox STIG
firefox_stig () {
    clear ; unset INSTALLED
    if [[ "$NAME" == "Ubuntu"* ]]; then
        INSTALLED="`dpkg -s firefox 2> /dev/null | grep 'Status'`"
    elif [[ "$NAME" == "Red Hat"* ]] || [[ "$NAME" == "Cent"* ]] ; then
        INSTALLED="`rpm -q firefox 2> /dev/null`"
    else
        echo "Unknown Operating System."
    fi
    if [[ $INSTALLED != "" ]] && [[ $INSTALLED != *"not installed"* ]]; then
        if [[ ! -f /opt/stigs/modules/firefox/stig-firefox.sh ]]; then
            echo "The Firefox STIG module was not found."
        else
            bash /opt/stigs/modules/firefox/stig-firefox.sh
        fi
    fi
}
##### Chrome STIG
chrome_stig () {
    clear ; unset INSTALLED
    if [[ "$NAME" == "Ubuntu"* ]]; then
        INSTALLED="`dpkg -s chromium-browser 2> /dev/null | grep 'Status'`"
    elif [[ "$NAME" == "Red Hat"* ]] || [[ "$NAME" == "Cent"* ]] ; then
        INSTALLED="`rpm -q chromium 2> /dev/null`"
    else
        echo "Unknown Operating System."
    fi
    if [[ $INSTALLED != "" ]] && [[ $INSTALLED != *"not installed"* ]]; then
        if [[ ! -f /opt/stigs/modules/chrome/stig-chrome.sh ]]; then
            echo "The Chrome STIG module was not found."
        else
            bash /opt/stigs/modules/chrome/stig-chrome.sh
        fi
    fi
}
##### Apache 2STIG
httpd_stig () {
    clear ; unset INSTALLED
    if [[ "$NAME" == "Ubuntu"* ]]; then
        INSTALLED="`dpkg -s apache2 2> /dev/null | grep 'Status'`"
    elif [[ "$NAME" == "Red Hat"* ]] || [[ "$NAME" == "Cent"* ]] ; then
        INSTALLED="`rpm -q httpd 2> /dev/null`"
    else
        echo "Unknown Operating System."
    fi
    if [[ $INSTALLED != "" ]] && [[ $INSTALLED != *"not installed"* ]]; then
        if [[ ! -f /opt/stigs/modules/apache24/stig-apache24.sh ]]; then
            echo "The Apache STIG module was not found."
        else
            bash /opt/stigs/modules/apache24/stig-apache24.sh
        fi
    fi
}
##### Bind9 STIG
bind_stig () {
    clear ; unset INSTALLED
    if [[ "$NAME" == "Ubuntu"* ]]; then
        INSTALLED="`dpkg -s bind9 2> /dev/null | grep 'Status'`"
    elif [[ "$NAME" == "Red Hat"* ]] || [[ "$NAME" == "Cent"* ]] ; then
        INSTALLED="`rpm -q bind9 2> /dev/null`"
    else
        echo "Unknown Operating System."
    fi
    if [[ $INSTALLED != "" ]] && [[ $INSTALLED != *"not installed"* ]]; then
        if [[ ! -f /opt/stigs/modules/bind9/stig-bind9.sh ]]; then
            echo "The Bind9 STIG module was not found."
        else
            bash /opt/stigs/modules/bind9/stig-bind9.sh
        fi
    fi
}
########## Start User Prompt ##########
until [[ "$SELECTION" = "4" ]]; do
    clear
    echo "################################################################################"
    unset SELECTION
    echo " Please select any installed Applications to with available STIG's. "
    echo " Enter the number, followed by enter, to select the option: "
    echo "  1. STIG Firefox"
    echo "  2. STIG Chrome"
    echo "  3. STIG Apache (httpd)"
#    echo "  4. STIG Bind9"  # NOT COMPLETE
    echo "  4. Return to Main Menu "
    echo -n "  Enter SELECTION: "; read SELECTION
    case $SELECTION in
        1)  firefox_stig ;;
        2)  chrome_stig ;;
        3)  httpd_stig ;;
#        4)  bind_stig ;;
        4)  ;;
        *)  echo " That was not a valid entry.  Please try again."
    esac
done
##### EOF
