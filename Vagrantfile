# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Require a recent version of vagrant otherwise some have reported errors 
# setting host names on boxes
Vagrant.require_version ">= 1.7.2"

CONFIG = {
  "box" =>	            ENV['box'] || "generic/ubuntu2304",
  "domain" =>               ENV['CLUSTER_DOMAIN'] || "c1.k8s.work",
  "network_name" =>         ENV['CLUSTER_NETWORK'] || "c1",
  "network_cidr" =>         ENV['CLUSTER_CIDR'] || "192.168.201.0/24",
  "domain_mac_seed" =>      ENV['DOMAIN_MAC_SEED'] || "52:54:40:00",
  "num_cp_nodes" =>         ENV['NUM_CP'] || "1",
  "cp_cores" =>             ENV['CP_CORES'] || "8",
  "cp_memory"  =>           ENV['CP_MEMORY'] || "16384",
  "cp_disk" =>              ENV['CP_DISK'] || "100", 
  "cp_mac" =>               ENV['CP_MAC'] || ":02",
  "num_worker_nodes" =>     ENV['NUM_WORKER'] || "1",
  "worker_cores" =>         ENV['WORKER_CORES'] || "8",
  "worker_memory"  =>       ENV['WORKER_MEMORY'] || "16384",
  "worker_disk" =>          ENV['WORKER_DISK'] || "100", 
  "worker_mac" =>           ENV['WORKER_MAC'] || ":03",
}


fix_dns = <<-TEXT
  sudo sed -i -e '/nameservers:/d' -e '/addresses:/d' /etc/netplan/01-netcfg.yaml
  cp /home/vagrant/files/netplan_eth1.yaml /etc/netplan/eth1.yaml
  chmod -R 600 /etc/netplan
  sudo netplan apply
  # sudo netplan generate && sudo netplan apply
  # sudo sed -i 's/^[[:alpha:]]/#&/' /etc/systemd/resolved.conf
  # sudo systemctl restart systemd-resolved.service

  sed -i 's/^DNS=.*/DNS=192.168.50.2/' /etc/systemd/resolved.conf
  sed -i 's/^Domains=.*/Domains=~c1.k8s.work/' /etc/systemd/resolved.conf
  sed -i 's/^DNSSEC=.*/DNSSEC=no/' /etc/systemd/resolved.conf
  sudo systemctl restart systemd-resolved.service
TEXT


bootstrap = <<-TEXT
pkg install -y os-frr

sed -i '' -e '/<\\/lo0>/r files/public.xml' /conf/config.xml
sed -i '' -e '/<\\/lo0>/r files/private.xml' /conf/config.xml
sed -i '' -e '/<filter>/r files/fw_private.xml' /conf/config.xml
sed -i '' -e 's/<domain>localdomain<\\/domain>/<domain>c1.k8s.work<\\/domain>/' /conf/config.xml
php ~/files/bgp.php quagga 'files/frr.xml'
php ~/files/bgp.php dhcpd 'files/dhcpd.xml'
php ~/files/bgp.php unbound 'files/unbound.xml'
# php ~/files/bgp.php nat 'files/nat.xml'
php ~/files/bgp.php gateways 'files/gateways.xml'


# Shutdown the system
reboot
TEXT



Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  config.vm.box = "#{CONFIG['box']}"

  config.vm.define "opnsense" do |node|
    vm_cpu = CONFIG['cp_cores']
    vm_disk = CONFIG['cp_disk']
    node.vm.box = "enrico204/opnsense"
    node.vm.provision "file", source: "files", destination: "files"
    node.vm.provision "shell", inline: bootstrap
    # node.vm.hostname = "opensense"
    node.vm.network "private_network",
      :ip => "192.168.50.2",
      :auto_config => false,
      # :libvirt__network_name => "host_only",
      :libvirt__dhcp_enabled => false,
      :libvirt__forward_mode => "none"
    node.vm.network "public_network",
      :dev => "bridge0",
      :libvirt__mac => "52:54:30:00:01:01"
      # :type => "bridge",
      # :ip => "192.168.1.21"
    node.vm.provider :libvirt do |domain|
      domain.cpus = "#{vm_cpu}".to_i
      domain.driver = 'kvm'
      domain.machine_virtual_size = "#{vm_disk}".to_i
      domain.management_network_mode = "nat"
      domain.management_network_mac = "52:54:00:8e:54:97"
      # domain.management_network_name = CONFIG['network_name']
      # domain.management_network_address = CONFIG['network_cidr']
      domain.memory = 16384
      domain.uri = 'qemu+unix:///system'
    end
  end
# 

  # config.vm.define "host1" do |node|
  #   vm_cpu = CONFIG['cp_cores']
  #   vm_disk = CONFIG['cp_disk']
  #   node.vm.box = "generic/ubuntu2304"
  #   node.vm.provision "shell",
  #     run: "always",
  #     inline: "ip route add default via 192.168.50.2"
  #   node.vm.provision "file", source: "rke_files", destination: "files"
  #   node.vm.provision "shell", path: "rke_scripts/rke_c1.sh"
  #   node.vm.hostname = "host1"
  #   # default router
  #   node.vm.network "private_network",
  #     :ip => "192.168.50.3",
  #     # :libvirt__network_name => "host_only",
  #     # :libvirt__dhcp_enabled => false,
  #     :libvirt__forward_mode => "none"
  #   node.vm.provider :libvirt do |domain|
  #     domain.cpus = "#{vm_cpu}".to_i
  #     domain.driver = 'kvm'
  #     domain.machine_virtual_size = "#{vm_disk}".to_i
  #     domain.management_network_mode = "none"
  #     # domain.management_network_mac = vm_mac
  #     # domain.management_network_name = CONFIG['network_name']
  #     # domain.management_network_address = CONFIG['network_cidr']
  #     domain.memory = 16384
  #     domain.uri = 'qemu+unix:///system'
  #   end
  # end

  CP = (CONFIG['num_cp_nodes']).to_i
  (1..CP).each do |i|
    vm_name = "cp0#{i}"
    vm_fqdn = "#{vm_name}.#{CONFIG['domain']}"
    vm_cpu = CONFIG['cp_cores']
    vm_cidr = CONFIG['network_cidr']
    vm_memory = CONFIG['cp_memory']
    vm_disk = CONFIG['cp_disk']
    vm_mac = "#{CONFIG['domain_mac_seed']}#{CONFIG['cp_mac']}:0#{i}"
    config.vm.define vm_name do |node|
      node.vm.hostname = "#{vm_fqdn}"
      node.vm.provision "rke_files", type: "file", source: "rke_files", destination: "files"
      node.vm.provision "fix_dns", type: "shell", name: "fix_dns", run: "once", inline: fix_dns, after: "rke_files"
      node.vm.provision "rke_c1", type: "shell", path: "rke_scripts/rke_c1.sh", after: "rke_files"
      node.vm.network "private_network",
        :ip => "192.168.50.21",
        :libvirt__mac => "52:54:30:00:02:0#{i}",
        :auto_config => false,
        # :libvirt__network_name => "host_only",
        :libvirt__dhcp_enabled => false,
        :libvirt__forward_mode => "none"
      node.vm.provider :libvirt do |domain|
        domain.cpus = "#{vm_cpu}".to_i
        domain.driver = 'kvm'
        domain.machine_virtual_size = "#{vm_disk}".to_i
        domain.management_network_mode = "nat"
        domain.management_network_mac = vm_mac
        # domain.management_network_name = CONFIG['network_name']
        # domain.management_network_address = CONFIG['network_cidr']
        domain.memory = "#{vm_memory}".to_i
        domain.uri = 'qemu+unix:///system'
      end
    end
  end

  WORKER = (CONFIG['num_worker_nodes']).to_i
  (1..WORKER).each do |i|
    vm_name = "worker0#{i}"
    vm_fqdn = "#{vm_name}.#{CONFIG['domain']}"
    vm_cpu = CONFIG['worker_cores']
    vm_memory = CONFIG['worker_memory']
    vm_disk = CONFIG['worker_disk']
    vm_mac = "#{CONFIG['domain_mac_seed']}#{CONFIG['worker_mac']}:0#{i}"
    config.vm.define vm_name, autostart: true do |node|
      node.vm.provision "shell", name: "fix_dns", run: "once", inline: fix_dns
      node.vm.hostname = "#{vm_fqdn}"
      node.vm.synced_folder "files/", "/files", type: "nfs", nfs_version: 4
      node.vm.provision "file", source: "rke_files", destination: "files"
      # node.vm.provision "shell", path: "rke_scripts/rke_agent.sh"
      node.vm.network "private_network",
        :ip => "192.168.50.3#{i}",
        :libvirt__mac => "52:54:30:00:03:01",
        :auto_config => false,
        # :libvirt__network_name => "host_only",
        :libvirt__dhcp_enabled => false,
        :libvirt__forward_mode => "none"
      node.vm.provider :libvirt do |domain|
        domain.cpus = "#{vm_cpu}".to_i
        domain.driver = 'kvm'
        domain.machine_virtual_size = "#{vm_disk}".to_i
        domain.management_network_mode = "nat"
        domain.management_network_mac = vm_mac
        # domain.management_network_name = CONFIG['network_name']
        # domain.management_network_address = CONFIG['network_cidr']
        domain.memory = "#{vm_memory}".to_i
        domain.uri = 'qemu+unix:///system'
      end
    end
  end

end