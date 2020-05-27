#! /bin/bash

# Install of nfs package
yum install nfs-utils -y

# Enable and start nfs-server and rpcbind
systemctl enable rpcbind nfs-server
systemctl start rpcbind nfs-server

# Creating directory for nfs share
mkdir -p /var/nfs/mount

# Changing access mode for nfs share and mount directory inside it
chmod -R 777 /var/nfs
chmod -R 777 /var/nfs/mount

# Configuring NFS service in compliance with home task
echo "[nfsd]" >> /etc/nfs.conf
echo "vers4=n" >> /etc/nfs.conf
echo "vers4.0=n" >> /etc/nfs.conf
echo "vers4.1=n" >> /etc/nfs.conf
echo "vers4.2=n" >> /etc/nfs.conf
echo "tcp=n" >> /etc/nfs.conf

# Configuring  export of NFS share
echo "/var/nfs 192.168.11.0/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports

# Reread NFS exports 
exportfs -r

#Enable firewall
systemctl start firewalld.service

# Creating rules for NFS share export
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind

# Reread firewall rules
firewall-cmd --reload
