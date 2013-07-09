#
#-*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.


  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
    config.vm.network :private_network, ip: "10.10.10.100"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # config.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []
  
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :rbenv=> {
        :rubies => ['2.0.0-p247'],
        :global => '2.0.0-p247',
        :gems =>{
          '2.0.0-p247' => [
            {:name => 'bundler'},
          ]
        } 
      },
      :nginx => {
        :source => {
          :modules => ['http_gzip_static_module' ,'http_ssl_module'],  
        },
        :init_style => 'upstart'
      },
      :site_conf => {
        :app_name => 'APP_NAME',
        :env => 'staging',
        :url => 'APP_URL',
        :ssh_keys => [
          'SSH DEPLOY KEY'
        ],
        :db_user => 'DB_USER',
        :db_name => 'DB_NAME',
        :db_password => 'DB_PASSWORD'
      },
      :postgresql => {
        :password => {
          :postgres => 'POSTGRES_PASSWORD'
        }
      },
      :nodejs => {
        :install_method => 'package'
      }
    }

    chef.run_list = [
      "recipe[apt]",
      "recipe[ruby_build]",
      "recipe[rbenv::system]",
      "recipe[nginx::source]",
      "recipe[postgresql]",
      "recipe[postgresql::server]",
      "recipe[database::postgresql]",
      "recipe[nodejs::install_from_package]",
      "recipe[site_conf]",
    ]
  end
end
