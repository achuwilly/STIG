#!/bin/bash
#
ckl-cleanup () {
    ls /root/reports/*.ckl | while read CKLFILE; do
        sed -i "s/|cr|/\n/g" $CKLFILE 2>/dev/null
        sed -i 's/AMPSMB/\&/g' $CKLFILE 2>/dev/null
        sed -i 's/AMPHTML/\&amp; /g' $CKLFILE 2>/dev/null
        sed -i 's/DQHTML/\&quot;/g' $CKLFILE 2>/dev/null
        sed -i 's/DQREPL/\&quot;/g' $CKLFILE 2>/dev/null
        sed -i 's/SQHTML/\&apos;/g' $CKLFILE 2>/dev/null
        sed -i 's/SQREPL/\&apos;/g' $CKLFILE 2>/dev/null
        sed -i 's/GTHTML/\&gt;/g' $CKLFILE 2>/dev/null
        sed -i 's/LTHTML/\&lt;/g'$CKLFILE 2>/dev/null
        sed -i 's|BSREPL|\/|g' $CKLFILE 2>/dev/null
        sed -i 's|DOLLARSMB|\$|g' $CKLFILE 2>/dev/null
        #sed -i "s/FINDING_DETAILS></FINDING_DETAILS>Verified compliant</" /root/reports/*ckl
    done
}
#
answer-overwrite () {
    if [[ "$CKLGIVEN" != "" ]] ; then
        CKLLIST="`grep -l ">V-$VULNNUM<" $CKLGIVEN/*.ckl 2>/dev/null`"
    else
        CKLLIST="`grep -l ">V-$VULNNUM<" /root/reports/*.ckl 2>/dev/null`"
    fi
    for CKLFILE in $CKLLIST ; do
        if [[ -f $CKLFILE ]]; then
            FINDING="`echo $FINDING | sed 's|\\$|DOLLARSMB|g' | sed 's/\"/DQREPL/g' | sed 's/\x27/SQREPL/g' | sed 's|/|BSREPL|g' | sed 's|>|GTSMB|g' | sed 's|<|LTSMB|g' | sed 's|\&|AMPSMB|g'`"
            COMMENT="`echo $COMMENT | sed 's/\"/DQREPL/g' | sed 's/\x27/SQREPL/g' | sed 's|/|BSREPL|g' | sed 's|>|GTSMB|g' | sed 's|<|LTSMB|g' | sed 's|\&|AMPSMB|g'`"
            if [[ "$STATUS" != "" ]] ; then  # Error Checking Status: NotAFinding, Not_Applicable, Not_Reviewed, or Open
                if [[ "$STATUS" != "NotAFinding" ]] && [[ "$STATUS" != "Not_Applicable" ]] && [[ "$STATUS" != "Not_Reviewed" ]] ; then STATUS="Open" ; fi
                sed -i "/V-$VULNNUM/,/<\/VULN>/ s/STATUS>.*</STATUS>$STATUS</" $CKLFILE
            fi
            if [[ "$FINDING" != "" ]]; then
                sed -i "/V-$VULNNUM/,/<\/VULN>/ s/FINDING_DETAILS>.*</FINDING_DETAILS>$FINDING</" $CKLFILE
            fi
            if [[ "$COMMENT" != "" ]]; then
                sed -i "/V-$VULNNUM/,/<\/VULN>/ s/COMMENTS>.*</COMMENTS>$COMMENT</" $CKLFILE
            fi
            if [[ "$OVERRIDE" != "" ]]; then
                sed -i "/V-$VULNNUM/,/<\/VULN>/ s/SEVERITY_OVERRIDE>.*</SEVERITY_OVERRIDE>$OVERRIDE</" $CKLFILE
            fi
            if [[ "$JUSTIFICATION" != "" ]]; then
                sed -i "/V-$VULNNUM/,/<\/VULN>/ s/SEVERITY_JUSTIFICATION>.*</SEVERITY_JUSTIFICATION>$JUSTIFICATION</" $CKLFILE
            fi
       else
           echo " The Vulnerability Number V-$VULNNUM was not found.  Please make sure the CKL for this exists."
        fi
    done
    unset VULNNUM STATUS FINDING COMMENT OVERRIDE JUSTIFICATION
    #XMLVULNNUM="`echo -e "grep $VULNNUM" | xmllint --shell $CKLFILE | head -1 | sed 's/.*VULN\[//' | sed 's/\].*//'`"
    #echo -e "cd /CHECKLIST/STIGS/iSTIG/VULN[$XMLVULNNUM]/FINDING_DETAILS\nset $FINDING\nsave" | xmllint --shell $CKLFILE
}
fix_ckl () {
    echo -n "Enter the full path for an individual CKL file (ex. /root/reports/rhel8.ckl): "; read CKLGIVEN
    if [[ ! -f "$CKLGIVEN" ]] ; then
        echo '-- The file provided was not found.'
    else
        awk '/<STATUS>/,/<\/STATUS>/' $CKLGIVEN | while read STATUSLINE ; do
            STATUSCHECK="`echo $STATUSLINE | awk -F'[>|<]' '{print $3}'`"
            if [[ "$STATUSCHECK" != "NotAFinding" ]] && [[ "$STATUSCHECK" != "Not_Applicable" ]] && [[ "$STATUSCHECK" != "Not_Reviewed" ]] && [[ "$STATUSCHECK" != "Open" ]] ; then
                sed -i "s/STATUS>$STATUSCHECK</STATUS>Open</" $CKLGIVEN
            fi
        done
    fi
    #REMSTIG_UUID="$(awk -F'[<|>]' '/VULN_ATTRIBUTE>STIG_UUID/ { getline; print $3 }' $CKLGIVEN | head -1)"
    #sed -i "s/>$REMSTIG_UUID/>/g" $CKLFILE
    #REMWEIGHT="$(awk -F'[<|>]' '/VULN_ATTRIBUTE>Weight/ { getline; print $3 }' $CKLGIVEN | head -1)"
    #sed -i "s/>$REMWEIGHT/>/g" $CKLFILE
    unset CKLGIVEN
}
#  Finds a Vulnerability and lists all CKL's that have it Open/Not Reviewed
find_opens () {
    echo -n "Enter the CKL directory (ex. /root/reports/): "; read CKLDIR
    if [[ "$CKLDIR" == '' ]] || [[ "$CKLDIR" == *".ckl" ]]; then
        echo 'No CKL File Path specified.'
        echo 'Would you like to use the default (/root/reports/): ' ; read ANSWER ; RESPONSE=${ANSWER^} < /dev/tty
        if [[ "$RESPONSE" == "Y"* ]]; then CKLDIR='/root/reports/' ; else exit 2 ; fi
    fi
    echo -n "Enter the Vulnerability ID Number (ex. 214800): "; read VULNNUM
    CKLDIR="$CKLDIR/*.ckl"
    for CKLFILE in $CKLDIR ; do
        CKLFILE="`echo $CKLFILE | sed 's/\/\//\//'`"
        awk "/V-$VULNNUM/{flag=1;next}/<\/VULN>/{flag=0}flag" $CKLFILE > "tmpVULN.txt"
        STATUS="$(awk '/<STATUS>/,/<\/STATUS>/' tmpVULN.txt | sed 's|.*<STATUS>||' | sed 's|<\/STATUS>.*||')"
        #FINDING="$(awk '/<FINDING_DETAILS>/,/<\/FINDING_DETAILS>/'  tmpVULN.txt | sed 's|.*<FINDING_DETAILS>||' | sed 's|<\/FINDING_DETAILS>.*||')"
        #COMMENT="$(awk '/<COMMENTS>/,/<\/COMMENTS>/'  tmpVULN.txt | sed 's|.*<COMMENTS>||' | sed 's|<\/COMMENTS>.*||')"
        if [[ "$STATUS" != *'NotAFinding'* ]] && [[ "$STATUS" != *'Not_Applicable'* ]] ; then
            echo "V-$VULNNUM - $STATUS - $CKLFILE" >> CKL_list.txt
        fi
        unset CKLFILE STATUS FINDING COMMENT OVERRIDE JUSTIFICATION
        rm -f tmpVULN.txt
    done
}
# Manually push Answer to all CKL's in a Directory
vuln-updater () {
    echo -n "Enter the CKL directory (ex. /root/reports/): "; read CKLGIVEN
    if [[ "$CKLGIVEN" == '' ]] || [[ "$CKLGIVEN" == *".ckl" ]]; then
        echo 'No CKL File Path specified. Using the default (/root/reports/): ' ; CKLGIVEN=''
    fi
    echo 'Any item left blank will remain unchanged.'
    echo -n "Enter the Vulnerability ID Number (ex. 214800): "; read VULNNUM
    echo -n "Enter the Status (Open, NotAFinding, Not_Applicable or Not_Reviewed): "; read STATUS
    if [[ "$STATUS" != "NotAFinding" ]] && [[ "$STATUS" != "Not_Applicable" ]] && [[ "$STATUS" != "Not_Reviewed" ]] ; then
        echo 'Status not recognized.  Leaving unchanged.' ; STATUS=''
    fi
    echo -n "Enter the Finding Details: "; read FINDING
    echo -n "Enter the Comments: "; read COMMENT
    answer-overwrite
    unset CKLGIVEN VULNNUM STATUS FINDING COMMENT OVERRIDE JUSTIFICATION
}
# List all Open/Not Reviewed in CKL
open-list () {
    echo -n "Enter the full path for an individual CKL file (ex. /root/reports/rhel8.ckl): "; read CKLGIVEN
    if [[ ! -f "$CKLGIVEN" ]] ; then
        echo '-- The file provided was not found.'
    else
        echo '-- Processing, please wait.'
        mkdir ./STIGtmp 2>/dev/null
        OUTPUTFILE="`echo $CKLGIVEN | sed 's/.*\///' | sed 's/\.ckl/\.txt/'`"
        echo "OPEN/Not_Reviewed -- $CKLGIVEN" > $OUTPUTFILE
        awk '/<\/STIG_INFO>/{ flag=1;next } /<\/CHECKLIST>/{flag=0} flag {print}' $CKLGIVEN > tmpvulndata.txt
        sed -i 's/"/\&quot\;/g' tmpvulndata.txt
        awk '/<VULN>$/{close("./STIGtmp/"S);S++}{print $0 > "./STIGtmp/"S}' tmpvulndata.txt
        for VULNTMPFILE in ./STIGtmp/* ; do
            VULNNUM="`awk -F'[<|>]' '/Vuln_Num/ { getline; print $3 }' $VULNTMPFILE`"
            STIGIDNUM="`awk -F'[<|>]' '/Rule_Ver/ { getline; print $3 }' $VULNTMPFILE`"
            SEVERITYRATE="`awk -F'[<|>]' '/Severity/ { getline; print $3 }' $VULNTMPFILE`"
            STATUS="`awk '/<STATUS>/,/<\/STATUS>/' $VULNTMPFILE | sed 's|.*<STATUS>||' | sed 's|<\/STATUS>.*||'`"
            FINDING="`awk '/<FINDING_DETAILS>/,/<\/FINDING_DETAILS>/' $VULNTMPFILE | sed 's|.*<FINDING_DETAILS>||' | sed 's|<\/FINDING_DETAILS>.*||'`"
            #COMMENT="`awk '/<COMMENTS>/,/<\/COMMENTS>/' $VULNTMPFILE | sed 's|.*<COMMENTS>||' | sed 's|<\/COMMENTS>.*||'`"
            if [[ $SEVERITYRATE == 'high' ]]; then SEVERITYRATE="CAT I"
            elif [[ $SEVERITYRATE == 'medium' ]]; then SEVERITYRATE="CAT II"
            else SEVERITYRATE="CAT III"
            fi
            if [[ "$STATUS" == "Open" ]] || [[ "$STATUS" == "Not_Reviewed" ]] ; then
                echo -e "-- V-$VULNNUM - $STIGIDNUM - $SEVERITYRATE - $STATUS \n-- Finding Details: $FINDING\n" >> $OUTPUTFILE
            fi
        done
        sed -i 's/\&quot\;/"/g' $OUTPUTFILE
        echo "For your results, please review: $OUTPUTFILE" ; sleep 2
        rm -rf ./STIGtmp tmp*.txt 2>/dev/null
    fi
    unset CKLGIVEN VULNNUM STIGIDNUM STATUS FINDING COMMENT OVERRIDE JUSTIFICATION
}
# END
