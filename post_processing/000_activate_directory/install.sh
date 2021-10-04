#!/bin/bash

## Automatisation of the process described in https://wiki.archlinux.org/title/Active_Directory_integration

echo "==========================================================="
echo "## Install Active Directory Support"
echo "==========================================================="

# 1. Configure resolv, ntp, samba, kerberos and nsswitch and update dhcpcd
templates=(ntp.conf resolv.conf krb5.conf nsswitch.conf)
for template in ${templates[@]}; do
    if [ -f /etc/${template} ]; then
        cp /etc/${template} /etc/${template}.backup
    fi
    cp templates/${template} /etc/
done

# Disable dhcpcd to overwrite /etc/resolv.conf
systemctl stop dhcpcd
echo "

# Don't overwrite /etc/resolv.conf
nohook resolv.conf
" >> /etc/dhcpcd.conf
systemctl start dhcpcd

if [ -f /etc/samba/smb.conf ]; then
    cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
fi
cp templates/smb.conf /etc/samba/

# 2. Configure PAM
#   - General WinBind configuration
if [ -f /etc/security/pam_winbind.conf ]; then
    cp /etc/security/pam_winbind.conf /etc/security/pam_winbind.conf.backup
fi
cp templates/pam_winbind.conf /etc/security/

#   - Adapt system authentication (/etc/pam.d/system-auth)
if [ -f /etc/pam.d/system-auth ]; then
    cp /etc/pam.d/system-auth /etc/pam.d/system-auth.backup
fi
sed -i '/^auth[ \t].*pam_unix.so/i auth\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth
sed -i '/^account[ \t]*required[ \t]*pam_unix.so/i account\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth
sed -i '/^password[ \t]*required[ \t]*pam_unix.so/i password\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth
sed -i '/^session[ \t]*required[ \t]*pam_unix.so/i session\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth

#   - Adapt user change (/etc/pam.d/su)
if [ -f /etc/pam.d/su ]; then
    cp /etc/pam.d/su /etc/pam.d/su.backup
fi
sed -i '/^auth[ \t]*required[ \t]*pam_unix.so/i auth\tsufficient\tpam_winbind.so' /etc/pam.d/su
sed -i '/^account[ \t]*required[ \t]*pam_unix.so/i account\tsufficient\tpam_winbind.so' /etc/pam.d/su
sed -i '/^password[ \t]*required[ \t]*pam_unix.so/i password\tsufficient\tpam_winbind.so' /etc/pam.d/su
sed -i '/^session[ \t]*required[ \t]*pam_unix.so/i session\tsufficient\tpam_winbind.so' /etc/pam.d/su

# 3. Update SSH
if [ -f /etc/ssh/sshd_config ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
fi
sed -i 's/^#\(KerberosAuthentication\|KerberosTicketCleanup\|KerberosGetAFSToken\|GSSAPIAuthentication\|GSSAPICleanupCredentials\)/\1/g' /etc/ssh/sshd_config

# 4. Configure SUDO
if [ -f /etc/sudoers ]; then
    cp /etc/sudoers /etc/sudoers.backup
fi
sed -i 's/^#[ \t]*%sudo/%sudo/g' /etc/sudoers
sed -i '/^%sudo/i %supermedia ALL=(ALL) ALL' /etc/sudoers

# 6. Enable services
services_to_start=(ntpd smb winbind) # See for nmb
for service in ${services_to_start[@]}; do
    systemctl enable $service
done

# 7. Force the clock to be set before joining the domain
ntpd -gq

# 7. Join the domain
echo "###############################################"
net ads join -U sigmediauser
