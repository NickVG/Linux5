# ДЗ NFS

Выполнено ДЗ по NFS.

Для развёртывания стенда используется дефолтовоый образ CentOS: 



Сделано

### 1. Напиcан Vagrantfile создающий две виртуальные машины со следующими параметрами:
		role:		NFS Server	NFS Client
		hostname:	nfsserver 	nfsclient
		IP:		192.168.11.101	192.168.11.102

### 2. Написаны скрипты для развёртывания тестовой лабы nfsserver.sh и nfscleint.sh для сервера и клиента соответственно. Скрипты выполнятся при запуске Vagrantfile.

#### Содержание скрипта nfsserver.sh (пояснения по работе скрипта находятся в его теле):
	
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
	echo "/var/nfs 192.168.11.0/24(rw,sync,root_squash,no_all_squash)" >> /etc/exports

		##/var/nfs - путь к папке, для которой предоставляется общий доступ;
		##192.168.11.0/24 –IP-подсеть, которой разрешён доступ к шаре;
		##(rw,sync,root_squash,no_all_squash) - набор опций для шары.
			###rw – доступ на чтение и запись (может принимать значение ro-только чтение);

			###sync – синхронный режим доступа(может принимать обратное значение- async). sync (async) - указывает, что сервер должен отвечать на запросы только после записи на диск изменений, выполненных этими запросами. Опция async указывает серверу не ждать записи информации на диск, что повышает производительность, но понижает надежность, т.к. в случае обрыва соединения или отказа оборудования возможна потеря данных;

			###no_root_squash – запрет подмены uid/gid для суперпользователя (root). По умолчанию пользователь root на клиентской машине не будет иметь доступа к разделяемой директории сервера. Этой опцией мы можем снять это ограничение. В целях безопасности этого делать НЕ стоит;

			###all_squash / no_all_squash - установка подмены идентификатора от всех пользователей all_squash - подмена запросов от ВСЕХ пользователей (не только root) на анонимного uid/gid, либо на пользователя, заданного в параметре anonuid/anongid. Используется обычно для публичного экспорта директорий. no_all_squash - запрет подмены uid/gid для от всех пользователей. Если данный параметр не указан,то используетс япараметр по-умолчанию: root_squash.

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
	
Дополнительно результат работы скриптов на сервере можно проверить с помощью комманд *rpcinfo -p localhost* и *exportfs*
	
#### Содержание скрипта nfsclient.sh (пояснения по работе скрипта находятся в его теле):

	#! /bin/bash
	
	# install nfs package
	# Установим пакеты nfs
	yum install nfs-utils -y
	
	# Включаем автозагрузку для служб rpcbind и запускаем эту службу (необходима для работы NFS)
	systemctl start rpcbind
	systemctl enable rpcbind
	
	# creating directory for nfs mount
	# Создаём директорию куда будет смонтирована шара
	mkdir /mnt/nfs-share
	
	# mount nfs share from nfs server
	# Монтируем шару в ранее созданную директорию
	mount -t nfs 192.168.11.101:/var/nfs/ /mnt/nfs-share/
	# Add NFS automount during reboot
	#добавляем запись в fstab для того, чтобы директорию монтировалась при загрузке системы автоматически
	echo "192.168.11.101:/var/nfs/ /mnt/nfs-share/ nfs defaults 0 0" >> /etc/fstab
	# Test of writability of mouny directory
	# Проверям возможность запись в примонтироованную шару.
	echo "SUCCES" >> /mnt/nfs-share/mount/tst.txt

Дополнительно результат работы скриптов на клиенте можно проверить с помощью командами *df -hT*, *mount*, *cat /etc/fstab*
