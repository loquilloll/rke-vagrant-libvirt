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

cp files/server-config.yaml /etc/rancher/rke2/config.yaml

mkdir -p /var/lib/rancher/rke2/server/manifests/

cp files/cilium_config.yaml /var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml

curl -sfL --retry 3 https://get.rke2.io | INSTALL_RKE2_VERSION=v1.30.1+rke2r1 sh -
systemctl enable --now rke2-server.service

mkdir -p /home/vagrant/.kube
cp /etc/rancher/rke2/rke2.yaml /home/vagrant/.kube/config
# sed -i 's/127\.0\.0\.1/192.168.201.21/' /home/vagrant/.kube/config
sed -i 's/default/rke2/' /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

