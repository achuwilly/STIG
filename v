#!/bin/bash
if [[ ! -d /opt/stigs/var ]]; then mkdir /opt/stigs/var ; fi
source /opt/stigs/var/sys-var.sh 2>/dev/null
##### Identify Hardware Information
build_hardware_var () {
    sed -i '/^.*HARDWARE_.*$/d' /opt/stigs/var/sys-var.sh 2>/dev/null
    dmidecode | sed -n '/BIOS Information/,/^$/p' 2>/dev/null > tmpbios.txt
    dmidecode | sed -n '/System Information/,/^$/p' 2>/dev/null > tmpsys.txt
    echo "########## HARDWARE_INFORMATION ##########
HARDWARE_VENDOR='$(grep 'Manufacturer:' tmpsys.txt | sed 's/.*: //')'
HARDWARE_PRODUCT='$(grep 'Product Name:' tmpsys.txt | sed 's/.*: //')'
HARDWARE_BIOSVER='$(grep 'Version:' tmpbios.txt | sed 's/.*: //')'
HARDWARE_RELEASED='$(grep 'Release Date:' tmpbios.txt | sed 's/.*: //')'
HARDWARE_SERIAL='$(grep 'Serial Number:' tmpsys.txt | sed 's/.*: //')'
HARDWARE_UUID='$(grep 'UUID:' tmpsys.txt | sed 's/.*: //')'" >> /opt/stigs/var/sys-var.sh
    rm -f tmp*.txt
}
##### Identify Operating System Information
build_os_var () {
    source /opt/stigs/var/sys-var.sh 2>/dev/null
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release 2>/dev/null
    elif [[ ! -f /etc/os-release ]] && [[ -f /etc/redhat-release ]]; then # RHEL 6
        echo "NAME=\"`cat /etc/redhat-release | sed 's/ release.*//'`\"" >> /etc/os-release
        echo "VERSION_ID=\"`cat /etc/redhat-release | awk '{gsub(/[^0-9.]/,"")}1'`\"" >> /etc/os-release
        echo "VARIANT=\"`cat /etc/redhat-release | sed 's/.*Linux //' | sed 's/ release.*//'`\"" >> /etc/os-release
        source /etc/os-release 2>/dev/null
    fi
    if [[ "$NAME" == "Red Hat"* ]] || [[ "$NAME" == "Cent"*  ]]; then
        export OS_SHRTNM="rhel`echo $VERSION_ID | cut -d'.' -f1`"
    elif [[ "$NAME" == "Ubuntu"* ]] ; then
        export OS_SHRTNM="ubtu`echo $VERSION_ID | cut -d'.' -f1`"
    fi
##VARIANT-START
    if [[ "$VARIANT" == "" ]] && [[ "$OS_PLTFRM" == "" ]]; then
        echo -n "Please designate S-Server or W-Workstations: "; read ANSWER ; RESPONSE=${ANSWER^}
        until [[ "$RESPONSE" == 'S'* ]] || [[ "$RESPONSE" == 'W'* ]]; do
            echo -n "*** That was not a valid selection. Press S or W and Enter to continue: "; read ANSWER ; RESPONSE=${ANSWER^} < /dev/tty
        done
        if [[ "$RESPONSE" == 'S'* ]]; then export VARIANT="Server" ; else export VARIANT="Workstation"; fi
        sed -i '/^VARIANT=.*$/d' /etc/os-release 2>/dev/null
        echo "VARIANT=\"$VARIANT\"" >> /etc/os-release
        source /etc/os-release 2>/dev/null
    fi
##VARIANT-END
    sed -i '/^.*OS_.*$/d' /opt/stigs/var/sys-var.sh 2>/dev/null
    echo "########## OS_INFORMATION ##########
OS_NAME='$NAME'
OS_VERSION='$VERSION_ID'
OS_PLTFRM='$VARIANT'
OS_SHRTNM='$OS_SHRTNM'
OS_BIT='$(getconf LONG_BIT)'" >> /opt/stigs/var/sys-var.sh
}
##### Pull Current Network Information
build_network_var () {
    sed -i '/^.*NETWORK_.*$/d' /opt/stigs/var/sys-var.sh 2>/dev/null
    ETH_ADAPTER="`ls /sys/class/net/ | grep '^e\|^n' | head -1`"
    NETWORK_MAILRELAY=`grep 'relayhost' /etc/postfix/main.cf 2>/dev/null | grep -v '#' | awk -F'[][]' '{print $2}'`
    NETWORK_DOMAIN="`hostname -d`"
    if [[ "$NETWORK_DOMAIN" == "" ]]; then NETWORK_DOMAIN="`echo $HOSTNAME | cut -d'.' -f2,3,4,5,6`" ; fi
    NETWORK_IPADR="`ip addr | grep -w 'inet' | grep -v '127.0' | awk '{print $2}' | sed 's|\/.*||' | head -1`"
    if [[ "$NETWORK_IPADR" == "127"* ]] || [[ "$NETWORK_IPADR" == "" ]]; then
        NETWORK_IPADR="`hostname -I | cut -d' ' -f1`"
    fi
    echo "########## NETWORK_INFORMATION ##########
NETWORK_HOSTNAME='$(hostname -s)'
NETWORK_DOMAIN='$NETWORK_DOMAIN'
NETWORK_ADAPTER='$ETH_ADAPTER'
NETWORK_IPADR='$NETWORK_IPADR'
NETWORK_MACADR='$(cat /sys/class/net/$ETH_ADAPTER/address | head -1)'
NETWORK_DNS1='$(grep ^'nameserver' /etc/resolv.conf 2>/dev/null | head -1 | cut -d' ' -f2)'
NETWORK_DNS2='$(grep ^'nameserver' /etc/resolv.conf 2>/dev/null | tail -1 | cut -d' ' -f2)'" >> /opt/stigs/var/sys-var.sh
    rm -f tmp*.txt
    sed -i '/NETWORK/ s/:/-/g' /opt/stigs/var/sys-var.sh 2>/dev/null # : to - (for xml)
}
##### Load local environment
local_env_var () {
    if [[ -f /opt/stigs/custom/env-var.sh ]]; then
        bash /opt/stigs/custom/env-var.sh
    fi
}
sed -i '/^$/d' /opt/stigs/var/sys-var.sh 2>/dev/null # Delete Blank lines
##### EOF
