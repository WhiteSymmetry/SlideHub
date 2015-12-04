# -*- mode: ruby -*-
# vi: set ft=ruby :
# =================================================#
# Ruby on Rails Development Environment            #
# U |  _"\ u U  /"\  u     ___     |"|    / __"| u #
#  \| |_) |/  \/ _ \/     |_"_|  U | | u <\___ \/  #
#   |  _ <    / ___ \      | |    \| |/__ u___) |  #
#   |_| \_\  /_/   \_\   U/| |\u   |_____||____/>> #
#   //   \\_  \\    >>.-,_|___|_,-.//  \\  )(  (__)#
#  (__)  (__)(__)  (__)\_)-' '-(_/(_")("_)(__)     #
# =================================================#
# you need to enable nfs on your local computer
# Ubuntu: sudo apt-get install nfs-kernel-server
# Mac   : sudo nfsd enable
Vagrant.configure(2) do |config|

  if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    puts '--- ERROR ---'
    puts 'This Vagrantfile is not compatible with Windows environment'
    puts 'exit program...'
    exit
  end

  unless Vagrant.has_plugin?('Bindfs')
    puts '--- WARNING ---'
    puts 'You need to install vagrant-bindfs plugin by the command as follow'
    puts 'exec vagrant plugin install vagrant-bindfs'
    puts 'exit program...'
    exit
  end

  config.vm.define :develop do |develop|
    develop.vm.box = 'opscode-ubuntu-14.04'
    develop.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box'
    develop.vm.network 'forwarded_port', guest: 3000, host: 3000
    develop.vm.network 'private_network', ip: '192.168.33.10'
    develop.vm.synced_folder File.dirname(__FILE__), '/vagrant-nfs', :nfs => { mount_options: ['dmode=777', 'fmode=777'] }
    develop.bindfs.bind_folder '/vagrant-nfs', '/home/vagrant/myapp', :owner => 'vagrant', :group => 'vagrant', :'create-as-user' => true, :perms => 'u=rwx:g=rx:o=rx', :'create-with-perms' => 'u=wrx:g=rwx:o=rwx', :'chown-ignore' => true, :'chgrp-ignore' => true, :'chmod-ignore' => true

    develop.vm.provider 'virtualbox' do |vb|
      vb.gui = false
      vb.memory = '1024'
    end

    if Vagrant.has_plugin?("vagrant-cachier")
      develop.cache.scope = :box
    end

    develop.vm.provision "file", source: "script/ruby_env.sh", destination: "/tmp/ruby_env.sh"
    develop.vm.provision "file", source: "script/oss_env.sh", destination: "/tmp/oss_env.sh"
    develop.vm.provision "shell", path: "script/develop.sh"
  end

  config.vm.define :staging do |staging|
    staging.vm.box = 'opscode-ubuntu-14.04'
    staging.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box'
    staging.vm.network 'private_network', ip: '192.168.33.200'

    staging.vm.provider 'virtualbox' do |vb|
      vb.gui = false
      vb.memory = '1024'
    end

    if Vagrant.has_plugin?("vagrant-cachier")
      staging.cache.scope = :box
    end

    ## Generate environment file for staging
    if File.exists?(File.dirname(__FILE__) + '/.env')
      out = ''
      File.read(File.dirname(__FILE__) + '/.env').each_line do |l|
        out += l.gsub(/OSS\_/, "export OSS_")
      end
      require "tempfile"
      file = Tempfile.new('env', '/tmp/')
      begin
        file.write(out)
        file.close
        staging.vm.provision "file", source: file.path, destination: "/tmp/environment"
      end
    end

    ## Deploy ssh secret key
    if ENV.has_key?('OSS_STAGING_SSH_SECRET_KEY') && File.exists?(ENV['OSS_STAGING_SSH_SECRET_KEY'])
      staging.vm.provision "file", source: ENV['OSS_STAGING_SSH_SECRET_KEY'], destination: "/tmp/id_rsa"
    end

    staging.vm.provision "file", source: "script/ruby_env.sh", destination: "/tmp/ruby_env.sh"
    staging.vm.provision "file", source: "script/oss_env.sh", destination: "/tmp/oss_env.sh"
    staging.vm.provision "shell", path: "script/staging.sh"

  end
end
