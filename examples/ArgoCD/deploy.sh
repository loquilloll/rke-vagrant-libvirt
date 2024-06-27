
# Configure Cilium
REV=$(helm history rke2-cilium -n kube-system --kube-context rke2 | awk 'END {print $1}')
APPLY=$(kubectl apply -f cilium_config.yaml  --context rke2 | awk 'END {print $2}')
# Wait for helm deployment only if a change was made.
if [[ "configured" == $APPLY ]]; then
  while (( $REV == $(helm history rke2-cilium -n kube-system --kube-context rke2 | awk 'END {print $1}') )); do
    echo "waiting for helm deployment"
    sleep 1
  done
  # Restart Cilium Agents
  kubectl rollout restart ds cilium -n kube-system --context rke2
  # Restart Cilium Operator
  kubectl rollout restart deploy cilium-operator -n kube-system --context rke2
fi

# Apply Demo manifests
kubectl apply -f ./manifests --context rke2