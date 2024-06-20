#!/bin/bash
##### Created by NSWC Crane ITD Linux Team
# Required Access Check
test "$(whoami)" != 'root' && ( echo " ***** This script must be run as root ***** " ; exit 2 )
chmod 755 -R /opt/stigs/
chown root:root -R /opt/stigs/
if [ ! -d /root/reports ]; then mkdir -p /root/reports ; fi
if [ ! -d /opt/stigs/var ]; then mkdir /opt/stigs/var ; fi
source /opt/stigs/bin/sys-check.sh
build_hardware_var ; build_os_var ; build_network_var ; local_env_var
source /opt/stigs/var/sys-var.sh
cd /opt/stigs/
# Evaluate Apps
bash /opt/stigs/bin/eval-apps.sh
# Evaluate OS
bash /opt/stigs/bin/eval-os.sh
# Apply Answer-File
bash /root/reports/answers-file 2>/dev/null
source /opt/stigs/bin/ckl-edit.sh ; ckl-cleanup 2>/dev/null
chmod 660 -R /root/reports 2>/dev/null
##### END
