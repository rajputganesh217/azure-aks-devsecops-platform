#!/bin/bash
# Argo-CD Installation Script — Run on the Jump Server after AKS is ready
# This installs Argo-CD into the cluster and applies the Application manifests

set -e

echo "=== Creating argocd namespace ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "=== Installing Argo-CD ==="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Waiting for Argo-CD to be ready ==="
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "=== Getting initial admin password ==="
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo ""
echo "============================================"
echo "Argo-CD is installed!"
echo "Admin User: admin"
echo "Admin Password: ${ARGOCD_PASSWORD}"
echo "============================================"
echo ""
echo "To access Argo-CD UI, run:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then visit: https://localhost:8080"
