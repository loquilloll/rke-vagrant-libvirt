#!/bin/bash
release=$(helm status rke2-cilium -n kube-system -o json | jq '{"version": .version, "status": .info.status}')
if [[ "$(kubectl apply -f rke_files/cilium_config.yaml  | cut -d' ' -f2-)" == "configured" ]]; then
  helm_status=$(echo "$release" | jq -r '.status')
  current_version=$(echo "$release" | jq -r '.version')
  next_version=$((current_version+1))
  until [ "$helm_status" == "deployed" ] && [ $current_version -eq $next_version ]; do
    release=$(helm status rke2-cilium -n kube-system -o json | jq '{"version": .version, "status": .info.status}')
    helm_status=$(echo "$release" | jq -r '.status')
    current_version=$(echo "$release" | jq -r '.version')
  done
fi
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium