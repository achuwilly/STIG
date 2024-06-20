#!/bin/bash
cd /opt/stigs/modules/rhel8/
bash /opt/stigs/modules/rhel8/configs-backup.sh
# V-230388,V-230390,V-230391,V-230392,V-230393,V-230394,V-230395,V-230396,V-230397,
# V-230397,V-230399,V-230400,V-230401,V-230476,V-230480,V-230483
cat /opt/stigs/modules/rhel8/configs/auditd.conf > /etc/audit/auditd.conf
# V-230386,V-230402,V-230403,V-230404,V-230405,V-230406,V-230407,V-230408,V-230409,
# V-230410,V-230412,V-230413,V-230414,V-230415,V-230416,V-230417,V-230418,V-230419,
# V-230420,V-230421,V-230422,V-230423,V-230424,V-230425,V-230426,V-230427,V-230428,
# V-230429,V-230430,V-230431,V-230432,V-230434,V-230435,V-230436,V-230437,V-230438,
# V-230439,V-230440,V-230441,V-230442,V-230443,V-230444,V-230445,V-230446,V-230447,
# V-230448,V-230449,V-230450,V-230451,V-230452,V-230453,V-230454,V-230455,V-230456,
# V-230457,V-230458,V-230459,V-230460,V-230461,V-230462,V-230463,V-230464,V-230465,
# V-230466,V-230467,V-230471
cat /opt/stigs/modules/rhel8/configs/audit.rules > /etc/audit/rules.d/audit.rules
# V-230471
chmod 640 /etc/audit/rules.d/*
chmod 640 /etc/audit/auditd.conf
# V-230226,V-230329,V-230354,V-230347,V-230352,V-230530
mkdir -p /etc/dconf/db/gdm.d/ /etc/dconf/db/local.d/ 2>/dev/null
cat /opt/stigs/modules/rhel8/configs/00-disable-CAD > /etc/dconf/db/local.d/00-disable-CAD
cat /opt/stigs/modules/rhel8/configs/00-screensaver > /etc/dconf/db/local.d/00-screensaver
cat /opt/stigs/modules/rhel8/configs/01-banner-message > /etc/dconf/db/local.d/01-banner-message
cat /opt/stigs/modules/rhel8/configs/02-login-screen > /etc/dconf/db/local.d/02-login-screen
cat /opt/stigs/modules/rhel8/configs/custom.conf > /etc/gdm/custom.conf
# V-230351
echo -e "[org/gnome/settings-daemon/peripherals/smartcard]\nremoval-action='lock-screen'" >> /etc/dconf/db/distro.d/20-authselect
echo '#
/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-enabled
/org/gnome/desktop/screensaver/lock-delay
/org/gnome/settings-daemon/plugins/media-keys/logout
/org/gnome/login-screen/disable-user-list
/org/gnome/login-screen/banner-message-text
/org/gnome/login-screen/banner-message-enable
/org/gnome/desktop/lockdown/disable-lock-screen' > /etc/dconf/db/local.d/locks/session
# V-230231,V-230324,V-230365,V-230366,V-230370,V-230378,V-230383
sed -i -e 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS  1/' -e 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS  60/' /etc/login.defs
sed -i -e 's/^PASS_MIN_LEN.*/PASS_MIN_LEN  15/' -e 's/^UMASK.*/UMASK  077/' /etc/login.defs
echo -e '#\nFAIL_DELAY  4' >> /etc/login.defs
# V-230373
sed -i 's/INACTIVE.*/INACTIVE=35/' /etc/default/useradd
# V-230313,V-230346
sed -i 's/.*End of file.*/*                hard    core            0\n*                hard    maxlogins       10\n# End of file/' /etc/security/limits.conf
# V-230314,V-230315
echo -e "ProcessSizeMax=0\nStorage=none" >> /etc/systemd/coredump.conf
# V-230484,V-230485,V-230486
sed -i 's/.*pool/#&/' /etc/chrony.conf
echo -e 'port 0\ncmdport 0\n' >> /etc/chrony.conf
# V-230265
echo -e '\nlocalpkg_gpgcheck=True' >> /etc/dnf/dnf.conf
# V-230228,V-230387,V-230479,V-230481,V-230482
sed -i 's/.*var\/log\/secure.*/auth\.\*,authpriv\.\*,daemon\.\*                              \/var\/log\/secure/' /etc/rsyslog.conf
echo -e '$DefaultNetstreamDriver gtls\n$ActionSendStreamDriverMode 1\n$ActionSendStreamDriverAuthMode x509/name' >> /etc/rsyslog.conf
# V-230225,V-230244,V-230288,V-230289,V-230290,V-230291,V-230296,V-230330,V-230380,
# V-230382,V-230527,V-230555,V-230556
sed -i '/^.*Banner.*$/d' /etc/ssh/sshd_config
sed -i '/^.*ClientAlive.*$/d' /etc/ssh/sshd_config
sed -i '/^.*Compression.*$/d' /etc/ssh/sshd_config
sed -i '/^.*IgnoreRhosts.*$/d' /etc/ssh/sshd_config
sed -i '/^.*IgnoreUserKnownHosts.*$/d' /etc/ssh/sshd_config
sed -i '/^.*KerberosAuthentication.*$/d' /etc/ssh/sshd_config
sed -i '/^.*GSSAPIAuthentication.*$/d' /etc/ssh/sshd_config
sed -i '/^.*PermitRootLogin.*$/d' /etc/ssh/sshd_config
sed -i '/^.*PermitEmptyPasswords .*$/d' /etc/ssh/sshd_config
sed -i '/^.*PermitUserEnvironment .*$/d' /etc/ssh/sshd_config
sed -i '/^.*StrictModes.*$/d' /etc/ssh/sshd_config
sed -i '/^.*PrintLastLog.*$/d' /etc/ssh/sshd_config
sed -i '/^.*Protocol.*$/d' /etc/ssh/sshd_config
sed -i '/^.*RekeyLimit.*$/d' /etc/ssh/sshd_config
sed -i '/^.*X11Forwarding.*$/d' /etc/ssh/sshd_config
sed -i '/^.*X11UseLocalhost.*$/d' /etc/ssh/sshd_config
sed -i 's/^SSH_USE_STRONG_RNG.*/SSH_USE_STRONG_RNG=32/' >> /etc/sysconfig/sshd
sed -i -e 's/.*Ciphers/# &/' -e 's/.*MACs/# &/' /etc/crypto-policies/back-ends/openssh.config
sed -i 's/.*CRYPTO_POLICY.*/#&/' /etc/crypto-policies/back-ends/opensshserver.config
echo '
Banner /etc/issue
ClientAliveInterval 600
ClientAliveCountMax 0
Compression delayed
IgnoreUserKnownHosts yes
KerberosAuthentication no
GSSAPIAuthentication no
PermitRootLogin no
PermitUserEnvironment no
PermitEmptyPasswords no
StrictModes yes
PrintLastLog yes
Protocol 2
RekeyLimit 1G 1h
X11Forwarding no
X11UseLocalhost yes
AllowGroups wheel sshusers' >> /etc/ssh/sshd_config
# V-230253
echo 'SSH_USE_STRONG_RNG=32' > /etc/sysconfig/sshd
# V-230251, V-230252
if [[ -L /etc/crypto-policies/back-ends/opensshserver.config ]]; then
    SSHSRVFILE="`readlink /etc/crypto-policies/back-ends/opensshserver.config`"
else
    SSHSRVFILE="/etc/crypto-policies/back-ends/opensshserver.config"
fi
sed -i 's/CRYPTO_POLICY=/#&/' $SSHSRVFILE
echo "CRYPTO_POLICY='-oCiphers=aes256-ctr,aes192-ctr,aes128-ctr -oMACS=hmac-sha2-512,hmac-sha2-256'" >> $SSHSRVFILE
fips-mode-setup --enable
unset SSHSRVFILE
# V-230348,V-230349,V-230350,V-230353
cat /opt/stigs/modules/rhel8/configs/tmux.sh > /etc/profile.d/tmux.sh
#echo -e '[ -n "$PS1" -a -z "$TMUX" ] && exec tmux' >> /etc/skel/.bashrc
sed -i 's/.*tmux.*/#&/' /etc/shells
echo -e 'set -g lock-after-time 900\nset -g remain-on-exit off\nset -g lock-command vlock' >> /etc/tmux.conf
# V-230266,V-230267,V-230268,V-230269,V-230270,V-230280,V-230311,V-230535,V-230536,
# V-230537,V-230538,V-230539,V-230540,V-230541,V-230542,V-230543,V-230544,V-230545,
# V-230556,V-230547,V-230548,V-230549
cat /opt/stigs/modules/rhel8/configs/sysctl.conf > /etc/sysctl.conf
# V-230357,V-230358,V-230359,V-230360,V-230361,V-230362,V-230363,V-230375,V-230377
cat /opt/stigs/modules/rhel8/configs/pwquality.conf > /etc/security/pwquality.conf
# V-230385
sed -i 's/umask.*/umask 077/' /etc/bashrc
sed -i 's/umask.*/umask 077/' /etc/csh.cshrc
# V-230470
sed -i 's/.*AuditBackend.*/AuditBackend=LinuxAudit/' /etc/usbguard/usbguard-daemon.conf
# V-230493,V-230494,V-230495,V-230496,V-230497,V-230498,V-230499,V-230503,V-230507
cat /opt/stigs/modules/rhel8/configs/blacklist.conf > /etc/modprobe.d/blacklist.conf
# V-230524
systemctl enable usbguard.service && systemctl start usbguard.service
echo 'allow with-interface equals { 09:*:* }
allow with-interface equals { 03:*:* }
allow with-interface equals { 0b:*:* }
allow with-interface equals { 03:*:* 0b:*:* }
' > /etc/usbguard/rules.conf
usbguard generate-policy >> /etc/usbguard/rules.conf
# V-230523
sed -i 's/permissive.*/permissive = 1/' /etc/fapolicyd/fapolicyd.conf
echo '# fapolicyd monitored partitions
/
/home
/tmp
/var
/var/tmp
/var/log
/var/log/audit' > /etc/fapolicyd/fapolicyd.mounts
#cat /opt/stigs/modules/rhel8/configs/fapolicyd.rules >> /etc/fapolicyd/fapolicyd.rules
# V-230531
echo 'CtrlAltDelBurstAction=none' >> /etc/systemd/system.conf
# V-230550
cat /opt/stigs/modules/rhel8/configs/postfix-main.cf > /etc/postfix/main.cf
# V-237642,V-237643
sed -i "s|$(grep ^'Defaults.*env' /etc/sudoers | head -1)|Defaults    \!rootpw\n&|" /etc/sudoers
sed -i "s|$(grep ^'Defaults.*env' /etc/sudoers | head -1)|Defaults    \!targetpw\n&|" /etc/sudoers
sed -i "s|$(grep ^'Defaults.*env' /etc/sudoers | head -1)|Defaults    \!runaspw\n&|" /etc/sudoers
sed -i "s|$(grep ^'Defaults.*env' /etc/sudoers | head -1)|Defaults    timestamp_timeout=0\n&|" /etc/sudoers
# V-230508,V-230509,V-230510
echo 'tmpfs  /dev/shm  tmpfs  defaults,nodev,nosuid,noexec  0  0' >> /etc/fstab
# V-230233,V-230237,V-230332,V-230334,V-230336,V-230337,V-230338,V-230340,V-230342,
# V-230344,V-230356,V-230368,V-230372,V-230381
cp /opt/stigs/modules/rhel8/configs/*auth-local /etc/pam.d/
mv /etc/pam.d/password-auth /etc/pam.d/password-auth-ac
mv /etc/pam.d/smartcard-auth /etc/pam.d/smartcard-auth-ac
mv /etc/pam.d/system-auth /etc/pam.d/system-auth-ac
ln -s /etc/pam.d/password-auth-local /etc/pam.d/password-auth
ln -s /etc/pam.d/smartcard-auth-local /etc/pam.d/smartcard-auth
ln -s /etc/pam.d/system-auth-local /etc/pam.d/system-auth
sed -i 's/ silent//'  /etc/pam.d/postlogin
chmod 644 /etc/pam.d/*
# V-230333,V-230335,V-230337,V-230339,V-230341,V-230343,V-230345
cat /opt/stigs/modules/rhel8/configs/faillock.conf > /etc/security/faillock.conf
# V-230274,V-230355,V-230372,V-230376
cat /opt/stigs/modules/rhel8/configs/sssd.conf > /etc/sssd/sssd.conf
# V-230263, V-230475,V-230551,V-230552
#sed -i -e '/xattrs/ !s/^CONTENT.*/&+xattrs/' -e '/acl/ !s/^CONTENT.*/&+acl/' /etc/aide.conf
echo '#
/usr/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/rsyslogd p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
aide -i
cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
aide -u
# V-230277, V-230278, V-230279, V-230468, V-230469, V-230491
grubby --update-kernel=ALL --args="page_poison=1"
grubby --update-kernel=ALL --args="vsyscall=none"
grubby --update-kernel=ALL --args="slub_debug=P"
grubby --update-kernel=ALL --args="audit=1"
grubby --update-kernel=ALL --args="audit_backlog_limit=8192"
grubby --update-kernel=ALL --args="pti=on"
# V-230299, V-230302, V-230511, V-230512, V-230513, V-230514, V-230515, V-230516, V-230517, V-230518, V-230519, V-244530
sed -i '/\/home/ s/defaults/defaults,nosuid,noexec/g' /etc/fstab
sed -i '/\/tmp / s/defaults/defaults,noexec,nosuid,nodev/' /etc/fstab
sed -i '/\/var\/log/ s/defaults/defaults,noexec,nosuid,nodev/' /etc/fstab
sed -i '/\/boot\/efi/ s/defaults/defaults,nosuid/g' /etc/fstab
# V-250315
mkdir -p /var/log/faillock
semanage fcontext -a -t faillog_t "/var/log/faillock(/.*)?"
restorecon -Rv /var/log/faillock
######################### Services #########################
for devicename in $(ip addr show | grep state | tr -s " " ":" | cut -d":" -f2); do ip link set dev $devicename multicast off promisc off; done
nmcli radio wifi off
systemctl mask ctrl-alt-del.target
systemctl mask debug-shell.service
systemctl mask systemd-coredump.socket
systemctl disable autofs
systemctl disable kdump.service
systemctl enable tmp.mount
systemctl enable auditd.service
systemctl enable ipsec
systemctl enable firewalld
systemctl enable fapolicyd
systemctl enable usbguard
######################### CRANE ADDITIONS #########################
# SELinux/Users
userdel games ; groupdel games
setsebool -P daemons_use_tty 1
semanage user -a -R "sysadm_r unconfined_r" -r "s0-s0:c0.c1023" sysadm_u
# V-230560, V-230561
yum remove -y iprutils tuned
# SSH Card Reader
echo 'PKCS11Provider /usr/lib64/opensc-pkcs11.so' >> /etc/ssh/ssh_config
#
exit
