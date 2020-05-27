#! /bin/bash

# install nfs package
yum install nfs-utils -y
# Ubstall and enable rpcbind (nfs based on it)
systemctl start rpcbind
systemctl enable rpcbind

# creating directory for nfs mount
mkdir /mnt/nfs-share
# mount nfs share from nfs server
mount -t nfs 192.168.11.101:/var/nfs/ /mnt/nfs-share/
# Add NFS automount during reboot
echo "192.168.11.101:/var/nfs/ /mnt/nfs-share/ nfs defaults 0 0" >> /etc/fstab
# Test of writability of mouny directory
echo "SUCCES" >> /mnt/nfs-share/mount/tst.txt
