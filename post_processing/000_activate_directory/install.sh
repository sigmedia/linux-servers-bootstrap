#!/bin/bash

## Automatisation of the process described in https://wiki.archlinux.org/title/Active_Directory_integration

# 1. Configure resolv, ntp, samba, kerberos and nsswitch
templates=(ntp.conf resolv.conf krb5.conf nsswitch.conf)
for template in ${templates[@]}; do
    if [ -f /etc/${template} ]; then
        cp /etc/${template} /etc/${template}.backup
    fi
    cp templates/${template} /etc/
done

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
sed -i '/^auth[ \t]*required[ \t]*pam_unix.so/i auth\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth
sed -i '/^account[ \t]*required[ \t]*pam_unix.so/i account\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth
sed -i '/^password[ \t]*required[ \t]*pam_unix.so/i password\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth
sed -i '/^session[ \t]*required[ \t]*pam_unix.so/i session\tsufficient\tpam_winbind.so' /etc/pam.d/system-auth

# #   - Adapt user change (/etc/pam.d/su) [FIXME: May not be useful]
# if [ -f /etc/pam.d/su ]; then
#     cp /etc/pam.d/su /etc/pam.d/su.backup
# fi
# sed -i '/^auth[ \t]*required[ \t]*pam_unix.so/i auth\tsufficient\tpam_winbind.so' /etc/pam.d/su
# sed -i '/^account[ \t]*required[ \t]*pam_unix.so/i account\tsufficient\tpam_winbind.so' /etc/pam.d/su
# sed -i '/^password[ \t]*required[ \t]*pam_unix.so/i password\tsufficient\tpam_winbind.so' /etc/pam.d/su
# sed -i '/^session[ \t]*required[ \t]*pam_unix.so/i session\tsufficient\tpam_winbind.so' /etc/pam.d/su

# 3. Configure SSH
if [ -f /etc/ssh/sshd_config ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
fi

echo "
# Change to no to disable s/key passwords
ChallengeResponseAuthentication no

# Kerberos options
KerberosAuthentication yes
#KerberosOrLocalPasswd yes
KerberosTicketCleanup yes
KerberosGetAFSToken yes

# GSSAPI options
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
" | tee -a /etc/ssh/sshd_config > /dev/null

# 4. Configure SUDO
if [ -f /etc/sudoers ]; then
    cp /etc/sudoers /etc/sudoers.backup
fi
sed -i 's/^#[ \t]*%sudo/%sudo/g' /etc/sudoers
sed -i '/^%sudo/i %supermedia ALL=(ALL) ALL' /etc/sudoers

# 5. Start services
systemctl enable smb.service
systemctl start smb.service

systemctl enable nmb.service
systemctl start nmb.service

systemctl enable winbind.service
systemctl start winbind.service

systemctl enable ntpd
systemctl start ntp

systemctl restart sshd
