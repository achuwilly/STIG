#!/bin/bash
source /opt/stigs/var/sys-var.sh 2>/dev/null
source /etc/os-release
#
stig_viewer () {
    STIGVIEWER="$(ls /opt/disa/STIGViewer* 2>/dev/null | tail -1)"
    if [[ "$STIGVIEWER" == "" ]] ; then
        if [[ -f "`ls /opt/stigs/tools/U_STIGViewer_2*_Linux.zip`" ]] ; then
            mkdir -p /opt/disa/ 2>/dev/null
            unzip -qo /opt/stigs/tools/U_STIGViewer_2*_Linux.zip -d /opt/disa/
            STIGVIEWER="$(ls /opt/disa/STIGViewer* | tail -1)"
            chmod 755 -R /opt/disa
            chown root:root -R /opt/disa
            bash $STIGVIEWER 2>/dev/null
        else
            echo 'Unable to find the STIG-Viewer files.'
        fi
    else
        bash $STIGVIEWER 2>/dev/null
    fi
}
#
getpam_func () { ### Read PAM.D Soft-Links
    if [[ "$OS_NAME" == *"Red Hat"* ]] || [[ "$OS_NAME" == *"Cent"* ]]; then # RHEL
        PAMSYSAUTH="`readlink /etc/pam.d/system-auth 2> /dev/null`"
        if [[ "$PAMSYSAUTH" == "" ]] ; then PAMSYSAUTH="/etc/pam.d/system-auth" ; fi
        if [[ "$PAMSYSAUTH" != "/etc/"* ]] ; then PAMSYSAUTH="/etc/pam.d/$PAMSYSAUTH" ; fi
        export PAMSYSAUTH
        PAMPWDAUTH="`readlink /etc/pam.d/password-auth 2> /dev/null`"
        if [[ "$PAMPWDAUTH" == "" ]] ; then PAMPWDAUTH="/etc/pam.d/password-auth" ; fi
        if [[ "$PAMPWDAUTH" != "/etc/"* ]] ; then PAMPWDAUTH="/etc/pam.d/$PAMPWDAUTH" ; fi
        export PAMPWDAUTH
        PAMSMARTCARD="`readlink /etc/pam.d/smartcard-auth 2> /dev/null`"
        if [[ "$PAMSMARTCARD" == "" ]] ; then PAMSMARTCARD="/etc/pam.d/smartcard-auth" ; fi
        if [[ "$PAMSMARTCARD" != "/etc/"* ]] ; then PAMSMARTCARD="/etc/pam.d/$PAMSMARTCARD" ; fi
        export PAMSMARTCARD
    elif [[ "$OS_NAME" == *"Ubuntu"* ]]; then # Ubuntu
        PAMCOMMONACCT="`readlink /etc/pam.d/common-account 2> /dev/null`"
        if [[ "$PAMCOMMONACCT" == "" ]] ; then PAMCOMMONACCT="/etc/pam.d/common-account" ; fi
        if [[ "$PAMCOMMONACCT" != "/etc/"* ]] ; then PAMCOMMONACCT="/etc/pam.d/$PAMCOMMONACCT" ; fi
        export PAMCOMMONACCT
        PAMCOMMONAUTH="`readlink /etc/pam.d/common-auth 2> /dev/null`"
        if [[ "$PAMCOMMONAUTH" == "" ]] ; then PAMCOMMONAUTH="/etc/pam.d/common-auth" ; fi
        if [[ "$PAMCOMMONAUTH" != "/etc/"* ]] ; then PAMCOMMONAUTH="/etc/pam.d/$PAMCOMMONAUTH" ; fi
        export PAMCOMMONAUTH
        PAMCOMMONPSWD="`readlink /etc/pam.d/common-password 2> /dev/null`"
        if [[ "$PAMCOMMONPSWD" == "" ]] ; then PAMCOMMONPSWD="/etc/pam.d/common-password" ; fi
        if [[ "$PAMCOMMONPSWD" != "/etc/"* ]] ; then PAMCOMMONPSWD="/etc/pam.d/$PAMCOMMONPSWD" ; fi
        export PAMCOMMONPSWD
        PAMCOMMONSESN="`readlink /etc/pam.d/common-session 2> /dev/null`"
        if [[ "$PAMCOMMONSESN" == "" ]] ; then PAMCOMMONSESN="/etc/pam.d/common-session" ; fi
        if [[ "$PAMCOMMONSESN" != "/etc/"* ]] ; then PAMCOMMONSESN="/etc/pam.d/$PAMCOMMONSESN" ; fi
        export PAMCOMMONSESN
    else
        echo " Unknown OS Version."
    fi
}
#
fixpam_func () { ### Re-link PAM.D files to '-local'
    getpam_func
    if [[ "$OS_NAME" == *"Red Hat"* ]] || [[ "$OS_NAME" == *"Cent"* ]]; then # RHEL/CentOS
        if [[ "$PAMSYSAUTH" != "/etc/pam.d/system-auth-local" ]] && [[ -f /opt/stigs/modules/$OS_SHRTNM/configs/system-auth-local ]]; then
            cat /opt/stigs/modules/$OS_SHRTNM/configs/system-auth-local > /etc/pam.d/system-auth-local
            chmod 644 /etc/pam.d/system-auth-local
            if [[ ! -L /etc/pam.d/system-auth ]] && [[ ! -f /etc/pam.d/system-auth-ac ]]; then
                mv /etc/pam.d/system-auth /etc/pam.d/system-auth-ac
            elif [[ -L /etc/pam.d/system-auth ]]; then
                rm -f /etc/pam.d/system-auth 2>/dev/null
            else echo "Unknown Error, check your '/etc/pam.d setup." ; fi
            ln -s /etc/pam.d/system-auth-local /etc/pam.d/system-auth
        fi
        if [[ "$PAMPWDAUTH" != "/etc/pam.d/password-auth-local" ]] && [[ -f /opt/stigs/modules/$OS_SHRTNM/configs/password-auth-local ]]; then
            cat /opt/stigs/modules/$OS_SHRTNM/configs/password-auth-local > /etc/pam.d/password-auth-local
            chmod 644 /etc/pam.d/password-auth-local
            if [[ ! -L /etc/pam.d/password-auth ]] && [[ ! -f /etc/pam.d/password-auth-ac ]]; then
                mv /etc/pam.d/password-auth /etc/pam.d/password-auth-ac
            elif [[ -L /etc/pam.d/password-auth ]]; then
                rm -f /etc/pam.d/password-auth 2>/dev/null
            else echo "Unknown Error, check your '/etc/pam.d setup." ; fi
            ln -s /etc/pam.d/password-auth-local /etc/pam.d/password-auth
        fi
        if [[ "$PAMSMARTCARD" != "/etc/pam.d/smartcard-auth-local" ]] && [[ -f /opt/stigs/modules/$OS_SHRTNM/configs/smartcard-auth-local ]]; then
            cat /opt/stigs/modules/$OS_SHRTNM/configs/smartcard-auth-local > /etc/pam.d/smartcard-auth-local
            chmod 644 /etc/pam.d/smartcard-auth-local
            if [[ ! -L /etc/pam.d/smartcard-auth ]] && [[ ! -f /etc/pam.d/smartcard-auth-ac ]]; then
                mv /etc/pam.d/smartcard-auth /etc/pam.d/smartcard-auth-ac
            elif [[ -L /etc/pam.d/smartcard-auth ]]; then
                rm -f /etc/pam.d/smartcard-auth 2>/dev/null
            else echo "Unknown Error, check your '/etc/pam.d setup." ; fi
            ln -s /etc/pam.d/smartcard-auth-local /etc/pam.d/smartcard-auth
        fi
    elif [[ "$OS_NAME" == *"Ubuntu"* ]]; then # Ubuntu
        if [[ "$PAMCOMMONAUTH" != "/etc/pam.d/common-auth-local" ]] && [[ -f /opt/stigs/modules/ubtu18/configs/common-auth-local ]]; then
            cat /opt/stigs/modules/$OS_SHRTNM/configs/common-auth-local > /etc/pam.d/common-auth-local
            if [[ -L /etc/pam.d/common-auth ]]; then rm -f /etc/pam.d/common-auth ; else mv /etc/pam.d/common-auth /etc/pam.d/common-auth-ac ; fi
            ln -s /etc/pam.d/common-auth-local /etc/pam.d/common-auth
            chmod 644 /etc/pam.d/common-auth-*
        fi
        if [[ "$PAMCOMMONACCT" != "/etc/pam.d/common-account-local" ]] && [[ -f /opt/stigs/modules/ubtu18/configs/common-account-local ]]; then
            cat /opt/stigs/modules/$OS_SHRTNM/configs/common-account-local > /etc/pam.d/common-account-local
            if [[ -L /etc/pam.d/common-account ]]; then rm -f /etc/pam.d/common-account ; else mv /etc/pam.d/common-account /etc/pam.d/common-account-ac ; fi
            ln -s /etc/pam.d/common-account-local /etc/pam.d/common-account
            chmod 644 /etc/pam.d/common-account-*
        fi
        if [[ "$PAMCOMMONPSWD" != "/etc/pam.d/common-password-local" ]] && [[ -f /opt/stigs/modules/ubtu18/configs/common-password-local ]]; then
            cat /opt/stigs/modules/$OS_SHRTNM/configs/common-password-local > /etc/pam.d/common-password-local
            if [[ -L /etc/pam.d/common-password ]]; then rm -f /etc/pam.d/common-password ; else mv /etc/pam.d/common-password /etc/pam.d/common-password-ac ; fi
            ln -s /etc/pam.d/common-password-local /etc/pam.d/common-password
            chmod 644 /etc/pam.d/common-password-*
        fi
        if [[ "$PAMCOMMONSESN" != "/etc/pam.d/common-session-local" ]] && [[ -f /opt/stigs/modules/ubtu18/configs/common-session-local ]]; then
            cat /opt/stigs/modules/$OS_SHRTNM/configs/common-session-local > /etc/pam.d/common-session-local
            if [[ -L /etc/pam.d/common-session ]]; then rm -f /etc/pam.d/common-session ; else mv /etc/pam.d/common-session /etc/pam.d/common-session-ac ; fi
            ln -s /etc/pam.d/common-session-local /etc/pam.d/common-session
            chmod 644 /etc/pam.d/common-session-*
        fi
    else
        echo " Unknown OS Version."
    fi
}
#
ipcalc_func () {
    for i in `seq 1 4` ; do
        individualOCTETS=`echo $1 | awk -v var="$i" -F'.' '{print $var}'`
        if [[ "$individualOCTETS" -le 255 ]] && [[ "$individualOCTETS" -ge 0 ]] ; then
            if [[ "$i" -eq "1" ]] && [[ "$individualOCTETS" -eq 0 ]] ; then
                IPRESULTS="0"
            elif [[ "$i" -eq "4" ]] && [[ "$individualOCTETS" -eq 0 ]] ; then
                IPRESULTS="0"
            else
                IPRESULTS=$((IPRESULTS+1))
            fi
        fi
    done
    if [[ "$IPRESULTS" == "4" ]] && [[ "`echo $1 | awk -F'.' '{print $5}'`" == "" ]] ; then
        echo 1
    else
        echo 0
    fi ; unset individualOCTETS IPRESULTS
}
#
misc-menu () {
    until [[ "$SELECTION" = "6" ]]; do
        clear
        echo "################################################################################"
        unset SELECTION
        echo " Please enter the number, followed by enter, to select the option: "
        echo "  1. List all CKL's in a Dir with specified open Vulnerability"
        echo "  2. Push Single answer to all CKL's in a Dir"
        echo "  3. List all Open/Not Reviewed items in a CKL"
        echo "  4. Fix Broken CKL File"
        echo "  5. DISA STIG Viewer App"
        echo "  6. EXIT/Quit Script"
        echo -n "  Enter SELECTION: "; read SELECTION
        case $SELECTION in
          1)  source /opt/stigs/bin/ckl-edit.sh ; find_opens ;;
          2)  source /opt/stigs/bin/ckl-edit.sh ; vuln-updater ;;
          3)  source /opt/stigs/bin/ckl-edit.sh ; open-list ;;
          4)  source /opt/stigs/bin/ckl-edit.sh ; fix_ckl ;;
          5)  source /opt/stigs/bin/misc-func.sh ; stig_viewer ;;
          6)  quit_func ;;
          *)  echo " That was not a valid entry.  Please try again."
        esac
    done
}
