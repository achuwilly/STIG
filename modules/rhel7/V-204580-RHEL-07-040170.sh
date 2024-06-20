#!/bin/bash
source /opt/stigs/var/sys-var.sh 2>/dev/null
source /opt/stigs/var/stig.info
echo "################################################################################"
echo "Rule Title:  The Red Hat Enterprise Linux operating system must display the Standard Mandatory DoD Notice and Consent Banner immediately prior to, or as part of, remote access logon prompts.
STIG ID: RHEL-07-040170  Rule ID: SV-204580r603261_rule  Vuln ID: V-204580
Severity: CAT II Class: Unclass"
STATUS="Open"
COMMENT="Verified that the required DoD Notice and Consent Banner is displayed as part of remote access logon prompts."
FINDING=`grep -iw "banner " /etc/ssh/sshd_config | grep -v "#"`
if [[ "$FINDING" == *"/etc/issue"* ]]; then
    printf "RESULTS: %40.50s [\033[1;32m PASSED \033[0m]\n"
    STATUS="NotAFinding"
else
    printf "RESULTS:  %40.50s [\033[0;31m FAILED \033[0m]\nThere is a Finding :: $FINDING\n\n"
    if [[ "$STIG" != *"M" ]] && [[ "$STIG" != "" ]]; then
        RESPONSE=$STIG
    else
        echo "Would you like to change '$FINDING' to 'Banner /etc/issue' in '/etc/ssh/sshd_config'?"
        echo -n "Please enter y-Yes or n-No, followed by Enter: "; read ANSWER ; RESPONSE=${ANSWER^} < /dev/tty
        until [[ "$RESPONSE" == 'Y'* ]] || [[ "$RESPONSE" == 'N'* ]]; do
            echo -n "*** That was not a valid selection. Press Y or N and Enter to continue: "; read ANSWER ; RESPONSE=${ANSWER^}  < /dev/tty
        done
    fi
    if [[ "$RESPONSE" == 'Y'* ]]; then
        STATUS="NotAFinding"
        FINDING="Verified compliant"
        sed -i -e '/^.*040170.*.*$/d' -e '/^.*Banner .*$/d' /etc/ssh/sshd_config
        echo -e '# STIG ID: RHEL-07-040170\nBanner \\etc\\issue' >> /etc/ssh/sshd_config
        echo "RHEL-07-040170 -- $COMMENT" >> /root/reports/changelog.txt
    else
        echo "Be sure to document your justification in the checklist, when completed."
        COMMENT=""
    fi
fi
##### Building Checklist Entry #####
VULNNUM="204580"
FINDING="`echo $FINDING | sed 's/\"/DQHTML/g' | sed "s/'/SQHTML/g" | sed 's|/|BSREPL|g' | sed 's|>|GTHTML|g' | sed 's|<|LTHTML|g' | sed 's|\& |AMPHTML|g' | sed 's|\&|AMPSMB|g'`"
COMMENT="`echo $COMMENT | sed 's/\"/DQHTML/g' | sed "s/'/SQHTML/g" | sed 's|/|BSREPL|g' | sed 's|>|GTHTML|g' | sed 's|<|LTHTML|g' | sed 's|\& |AMPHTML|g' | sed 's|\&|AMPSMB|g'`"
sed -i "/V-$VULNNUM/,/<\/VULN>/ s/STATUS>.*</STATUS>$STATUS</" /root/reports/os.ckl
sed -i "/V-$VULNNUM/,/<\/VULN>/ s/FINDING_DETAILS>.*</FINDING_DETAILS>$FINDING</" /root/reports/os.ckl
sed -i "/V-$VULNNUM/,/<\/VULN>/ s/COMMENTS>.*</COMMENTS>$COMMENT</" /root/reports/os.ckl
##### EOF
