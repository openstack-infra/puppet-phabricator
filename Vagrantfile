VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "trusty" do |trusty|
    trusty.vm.box = "ubuntu/trusty64"
    trusty.vm.network 'private_network', ip: '192.168.99.10'
  end

  config.vm.provision "shell",
      path: "vagrant.sh"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "./"
    puppet.manifest_file  = "vagrant.pp"
  end
end
