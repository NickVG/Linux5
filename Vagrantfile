# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :nfsserver => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
	:disks => {
		:sata1 => {
			:dfile => './disks/sata1.vdi',
			:size => 250,
			:port => 1
		},
		:sata2 => {
                        :dfile => './disks/sata2.vdi',
                        :size => 250, # Megabytes
			:port => 2
                }
        }
  },

  :nfsclient => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.102',
        :disks => {
                :sata1 => {
                        :dfile => './disks/sata8.vdi',
                        :size => 250,
                        :port => 1
                },
                :sata2 => {
                        :dfile => './disks/sata9.vdi',
                        :size => 250, # Megabytes
                        :port => 2
                }
	}
  },
}


Vagrant.configure("2") do |config|

    MACHINES.each do |boxname, boxconfig|

        config.vm.define boxname do |box|

            box.vm.box = boxconfig[:box_name]

            box.vm.host_name = boxname.to_s

            box.vm.network "private_network", ip: boxconfig[:ip_addr]

            box.vm.provider :virtualbox do |vb|

                    vb.customize ["modifyvm", :id, "--memory", "1024"]

            end

            box.vm.provision "shell", inline: <<-SHELL

               mkdir -p ~root/.ssh
               cp ~vagrant/.ssh/auth* ~root/.ssh

           SHELL

           end

       end

       config.vm.define "nfsserver" do |nfsserver|

         nfsserver.vm.provision "shell", path: "./scripts/nfsserver.sh"
       end

       config.vm.define "nfsclient" do |nfsclient|
         nfsclient.vm.provision "shell", path: "./scripts/nfsclient.sh"

       end

  end

