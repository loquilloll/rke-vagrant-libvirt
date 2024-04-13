mkdir -p /etc/rancher/rke2/

cp files/config.yaml /etc/rancher/rke2/config.yaml

mkdir -p /var/lib/rancher/rke2/server/manifests/

cp files/cilium_config.yaml /var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml

curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=v1.29.1+rke2r1 sh -
systemctl enable --now rke2-server.service

mkdir -p /home/vagrant/.kube
cp /etc/rancher/rke2/rke2.yaml /home/vagrant/.kube/config
# sed -i 's/127\.0\.0\.1/192.168.201.21/' /home/vagrant/.kube/config
sed -i 's/default/rke2/' /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

