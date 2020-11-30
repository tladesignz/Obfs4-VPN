# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/debian10"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  #config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  #config.vm.network "forwarded_port", guest: 3306, host: 3306, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  #config.vm.synced_folder ".", "/var/www/html/ci", owner: "www-data", group: "www-data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt upgrade -y
    apt autoremove -y
    apt autoclean -y
    apt install -y joe obfs4proxy

    mkdir -p /var/lib/tor/pt_state/obfs4

    pushd /var/lib/tor/pt_state/obfs4 > /dev/null

    echo "TOR_PT_MANAGED_TRANSPORT_VER=1" > obfs4.config
    echo "TOR_PT_STATE_LOCATION=/var/lib/tor/pt_state/obfs4" >> obfs4.config
    echo "TOR_PT_SERVER_TRANSPORTS=obfs4" >> obfs4.config
    echo "TOR_PT_SERVER_BINDADDR=obfs4-0.0.0.0:12345" >> obfs4.config

    # TODO: Where to route to?
    echo "TOR_PT_ORPORT=127.0.0.1:12346" >> obfs4.config

    popd > /dev/null

    pushd /etc/systemd/system > /dev/null

    echo "[Unit]" > obfs4proxy.service
    echo "Description=obfs4proxy Server" >> obfs4proxy.service
    echo "" >> obfs4proxy.service
    echo "[Service]" >> obfs4proxy.service
    echo "EnvironmentFile=/var/lib/tor/pt_state/obfs4/obfs4.config" >> obfs4proxy.service
    echo "ExecStart=/usr/bin/obfs4proxy -enableLogging true -logLevelStr INFO" >> obfs4proxy.service
    echo "" >> obfs4proxy.service
    echo "[Install]" >> obfs4proxy.service
    echo "WantedBy=multi-user.target" >> obfs4proxy.service

    popd > /dev/null

    systemctl start obfs4proxy
    systemctl enable obfs4proxy

    cat /var/lib/tor/pt_state/obfs4/obfs4_bridgeline.txt

  SHELL
end
