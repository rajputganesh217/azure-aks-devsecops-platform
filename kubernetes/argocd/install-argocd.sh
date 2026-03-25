#!/bin/bash
# Argo-CD Automated Installation Script
# Run on the Jump Server after AKS is ready
# This installs Argo-CD, exposes it via App Gateway Ingress, and deploys all applications

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Creating argocd namespace ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "=== Installing Argo-CD ==="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Waiting for Argo-CD to be ready ==="
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "=== Exposing Argo-CD via App Gateway Ingress ==="
kubectl apply -f "$SCRIPT_DIR/argocd-ingress.yaml"

echo "=== Deploying ArgoCD Applications (dev + qa) ==="
kubectl apply -f "$SCRIPT_DIR/applications.yaml"

echo ""
echo "============================================"
echo "  Argo-CD is installed and fully configured!"
echo "============================================"

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo ""
echo "  Admin User:     admin"
echo "  Admin Password: ${ARGOCD_PASSWORD}"
echo ""
echo "  Dashboard URL:  https://argocd.microservices.local"
echo "  (Add this to your hosts file with App Gateway IP)"
echo ""
echo "  Applications deployed:"
echo "    - platform-dev (namespace: dev)"
echo "    - platform-qa  (namespace: qa)"
echo "============================================"
