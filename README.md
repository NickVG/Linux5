# ДЗ NFS

Выполнено ДЗ по NFS.

Для развёртывания стенда используется дефолтовоый образ CentOS: 



Сделано

## 1. Напиcан Vagrantfile создающий две виртуальные машины со следующими параметрами:
		role:		NFS Server	NFS Client
		hostname:	nfsserver 	nfsclient
		IP:		192.168.11.101	192.168.11.102

## 2. Написаны скрипты для развёртывания тестовой лабы nfsserver.sh и nfscleint.sh для сервера и клиента соответственно. Скрипты выполнятся при запуске Vagrantfile.

Содержание скрипта nfsserver.sh (пояснения по работе скрипта находятся в его теле):
	
	#! /bin/bash
	
	# Install of nfs package
	# Установим пакеты nfs
	yum install nfs-utils -y

	# Enable and start nfs-server and rpcbind
	# Включаем автозагрузку для служб rpcbind и nfs-server и запускаем службы
	systemctl enable rpcbind nfs-server
	systemctl start rpcbind nfs-server

	# Creating directory for nfs share
	# Создаём каталог под NFS-шару
	mkdir -p /var/nfs/mount

	# Changing access mode for nfs share and mount directory inside it
	# Позволяем запись в директорию
	chmod -R 777 /var/nfs
	chmod -R 777 /var/nfs/mount

	# Configuring NFS service in compliance with home task
	# Выполняем условия ДЗ
	# отключем nfs всех версий кроме 3
	echo "[nfsd]" >> /etc/nfs.conf
	echo "vers4=n" >> /etc/nfs.conf
	echo "vers4.0=n" >> /etc/nfs.conf
	echo "vers4.1=n" >> /etc/nfs.conf
	echo "vers4.2=n" >> /etc/nfs.conf
	# отключем доступ по tcp
	echo "tcp=n" >> /etc/nfs.conf

	# Configuring  export of NFS share
	# Создаём NFS-шару в файле /etc/exports
	echo "/var/nfs 192.168.11.0/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports

	# Reread NFS exports 
	# перезапускаем экспорт NFS для того, чтобы заработал экспорт настроенной шары
	exportfs -r

	#Enable firewall
	# Включаем службу фаеровола
	systemctl start firewalld.service

	# Creating rules for NFS share export
	# Создаём правила фаервола для работоспсобности NFS
	firewall-cmd --permanent --zone=public --add-service=nfs
	firewall-cmd --permanent --zone=public --add-service=mountd
	firewall-cmd --permanent --zone=public --add-service=rpc-bind

	# Reread firewall rules
	# Перечитываем правила фаервола
	firewall-cmd --reload
	
