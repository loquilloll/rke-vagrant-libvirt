REV=$(helm history rke2-cilium -n kube-system --kube-context rke2 | awk 'END {print $1}')
kubectl apply -f $1  --context rke2
if (( $REV == $(helm history rke2-cilium -n kube-system --kube-context rke2 | awk 'END {print $1}') )); then
  echo "waiting for helm deployment"
  sleep 1
fi
kubectl rollout restart ds cilium -n kube-system --context rke2
kubectl rollout restart deploy cilium-operator -n kube-system --context rke2