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

mkdir -p /etc/rancher/rke2/
cp files/worker-config.yaml /etc/rancher/rke2/config.yaml

curl -sfL --retry 3 https://get.rke2.io | INSTALL_RKE2_TYPE="agent" INSTALL_RKE2_VERSION=v1.30.1+rke2r1 sh -
systemctl enable --now rke2-agent.service
