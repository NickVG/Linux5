#! /bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g,h}
echo y | mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
echo y | mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{g,h}
mdadm -D /dev/md0
mdadm -D /dev/md1
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
cp /etc/mdadm/mdadm.conf /vagrant/mdadm.conf
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

#for i in $(seq 1 5); do sudo echo "/dev/md0p1    /raid/part$i ext4  defaults    1 2"; done 
for ((i=1; i<6; i++))
do
echo /dev/md0p$i    /raid/part$i ext4  defaults    1 2 >> /etc/fstab
done
