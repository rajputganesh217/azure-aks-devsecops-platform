#!/bin/bash
# ============================================================
# Argo-CD Fully Automated Installation Script
# ============================================================
# This script is called by the database Jenkins pipeline on
# the Jump Server AFTER the first namespace (dev) is deployed.
# It is idempotent — safe to run multiple times.
#
# Required environment variables:
#   CSI_IDENTITY_CLIENT_ID  — Managed Identity client ID for CSI
#   AZURE_TENANT_ID         — Azure AD tenant ID
#
# Usage:
#   CSI_IDENTITY_CLIENT_ID=xxx AZURE_TENANT_ID=yyy ./install-argocd.sh [source-ns]
# ============================================================

set -e

NAMESPACE_SOURCE="${1:-dev}"   # Namespace to copy TLS secret from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate required environment variables
if [ -z "$CSI_IDENTITY_CLIENT_ID" ]; then
    echo "ERROR: CSI_IDENTITY_CLIENT_ID is not set"; exit 1
fi
if [ -z "$AZURE_TENANT_ID" ]; then
    echo "ERROR: AZURE_TENANT_ID is not set"; exit 1
fi

echo "=== Step 1: Creating argocd namespace ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "=== Step 2: Installing Argo-CD (Server-Side Apply) ==="
kubectl apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Step 3: Waiting for Argo-CD server to be ready ==="
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "=== Step 4: Patching Argo-CD to run in insecure mode (HTTP backend) ==="
CURRENT_ARGS=$(kubectl get deployment argocd-server -n argocd \
  -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null || echo "")
if echo "$CURRENT_ARGS" | grep -q "insecure"; then
    echo "Already patched to insecure mode. Skipping."
else
    kubectl patch deployment argocd-server -n argocd --type='json' -p='[
      {"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["argocd-server"]},
      {"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--insecure"]}
    ]'
    kubectl rollout status deployment/argocd-server -n argocd --timeout=120s
fi

echo "=== Step 5: Copying TLS secret from ${NAMESPACE_SOURCE} to argocd namespace ==="
if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing..."
    sudo apt-get update -qq && sudo apt-get install -y -qq jq > /dev/null 2>&1 || true
fi

if kubectl get secret microservices-tls-secret -n "$NAMESPACE_SOURCE" > /dev/null 2>&1; then
    kubectl get secret microservices-tls-secret -n "$NAMESPACE_SOURCE" -o json | \
      jq '.metadata.namespace = "argocd" | del(.metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp)' | \
      kubectl apply --overwrite=true -f -
    echo "TLS secret copied successfully."
else
    echo "WARNING: TLS secret not found in ${NAMESPACE_SOURCE}. ArgoCD Ingress may not work over HTTPS."
fi

echo "=== Step 6: Applying ArgoCD Ingress (App Gateway with TLS) ==="
cat <<'INGRESS_EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    appgw.ingress.kubernetes.io/backend-protocol: "http"
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
    appgw.ingress.kubernetes.io/health-probe-path: "/healthz"
    appgw.ingress.kubernetes.io/cookie-based-affinity: "true"
spec:
  ingressClassName: azure-application-gateway
  tls:
  - hosts:
    - argocd.microservices.local
    secretName: microservices-tls-secret
  rules:
    - host: argocd.microservices.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
INGRESS_EOF

echo "=== Step 7: Rendering & Applying ArgoCD Applications (Helm Template) ==="
# Render each environment's Application manifest using helm template
for ENV_FILE in "$SCRIPT_DIR"/values-*.yaml; do
    ENV_NAME=$(basename "$ENV_FILE" | sed 's/values-//;s/\.yaml//')
    echo "--- Rendering application for environment: ${ENV_NAME} ---"

    helm template "platform-${ENV_NAME}" "$SCRIPT_DIR" \
      -f "$SCRIPT_DIR/values.yaml" \
      -f "$ENV_FILE" \
      --set csi.clientId="$CSI_IDENTITY_CLIENT_ID" \
      --set csi.tenantId="$AZURE_TENANT_ID" \
    | kubectl apply --server-side --force-conflicts -f -

    echo "Applied platform-${ENV_NAME} ArgoCD Application."
done

echo ""
echo "============================================"
echo "  Argo-CD Setup Complete!"
echo "============================================"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "N/A")
echo "  Admin User:     admin"
echo "  Admin Password: ${ARGOCD_PASSWORD}"
echo "  Dashboard URL:  https://argocd.microservices.local"
echo "============================================"
