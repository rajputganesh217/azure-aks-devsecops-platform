#!/bin/bash
# ============================================================
# Runtime Container Security Setup
# ============================================================
# Installs Falco for runtime threat detection on AKS
# and Trivy Operator for continuous vulnerability scanning
# of running containers.
#
# Called by database pipeline after ArgoCD is set up.
# Idempotent — safe to run multiple times.
# ============================================================

set -e

echo "============================================"
echo "  Runtime Security Setup"
echo "============================================"

# ─── Step 0: Dependency Checks ───
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl not found. Please ensure it is installed and configured on the Jump Server."
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "helm not found. Installing..."
    curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || true
fi

if ! command -v helm &> /dev/null; then
    echo "ERROR: helm installation failed. Please install helm manually on the Jump Server."
    exit 1
fi

# ─── Step 1: Install Falco (Runtime Threat Detection) ───
echo ""
echo "=== Step 1: Installing Falco ==="
kubectl create namespace falco --dry-run=client -o yaml | kubectl apply -f -

# Add Falco Helm repo
helm repo add falcosecurity https://falcosecurity.github.io/charts 2>/dev/null || true
helm repo update

# Install/Upgrade Falco with modern eBPF driver
helm upgrade --install falco falcosecurity/falco \
  --namespace falco \
  --set driver.kind=modern_ebpf \
  --set falcosidekick.enabled=true \
  --set falcosidekick.webui.enabled=false \
  --set collectors.containerd.enabled=true \
  --set collectors.containerd.socket=/run/containerd/containerd.sock \
  --set tty=true \
  --wait --timeout 300s

echo "Falco installed successfully!"

# ─── Step 2: Install Trivy Operator (Continuous Vulnerability Scanning) ───
echo ""
echo "=== Step 2: Installing Trivy Operator ==="
kubectl create namespace trivy-system --dry-run=client -o yaml | kubectl apply -f -

helm repo add aqua https://aquasecurity.github.io/helm-charts/ 2>/dev/null || true
helm repo update

helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set trivy.ignoreUnfixed=true \
  --set operator.scanJobTimeout=10m \
  --set operator.vulnerabilityScannerEnabled=true \
  --set operator.configAuditScannerEnabled=true \
  --set operator.rbacAssessmentScannerEnabled=true \
  --wait --timeout 300s

echo "Trivy Operator installed successfully!"

# ─── Step 3: Verify ───
echo ""
echo "============================================"
echo "  Runtime Security Status"
echo "============================================"
echo ""
echo "Falco pods:"
kubectl get pods -n falco --no-headers 2>/dev/null || echo "  (waiting for pods to start)"
echo ""
echo "Trivy Operator pods:"
kubectl get pods -n trivy-system --no-headers 2>/dev/null || echo "  (waiting for pods to start)"
echo ""
echo "============================================"
echo "  What's Protected:"
echo "  - Falco: Detects shell spawns in containers,"
echo "    privilege escalation, suspicious file access,"
echo "    crypto mining, and outbound connections."
echo "  - Trivy Operator: Continuously scans running"
echo "    container images for new CVEs."
echo "============================================"
echo ""
echo "Check vulnerability reports:"
echo "  kubectl get vulnerabilityreports -A"
echo "  kubectl get configauditreports -A"
echo "  kubectl get rbacassessmentreports -A"
echo ""
