# Azure AKS DevSecOps Microservices Platform

This project demonstrates deploying a **containerized microservices application on Azure Kubernetes Service (AKS)** using **Terraform, Docker, Azure Container Registry (ACR), Jenkins CI/CD, and DevSecOps security tools**.

The platform follows a **DevSecOps pipeline approach** where infrastructure, containers, and security scans are automated.

---

# Application Architecture

The application consists of **four containers**:

| Service  | Description                         |
| -------- | ----------------------------------- |
| Frontend | Nginx static web UI                 |
| Backend  | Python Flask REST API               |
| Worker   | Background order processing service |
| Database | PostgreSQL database                 |

---

# Architecture Overview

```
User
 │
 ▼
Frontend (Nginx)
 │
 ▼
Backend API (Flask)
 │
 ▼
PostgreSQL Database
 │
 ▼
Worker Service
```

Infrastructure components:

* Azure Kubernetes Service (**AKS**)
* Azure Container Registry (**ACR**)
* Terraform Infrastructure as Code
* Jenkins CI/CD pipelines
* DevSecOps security scanning tools

---

# DevSecOps Tools Used

| Tool                     | Purpose                          |
| ------------------------ | -------------------------------- |
| Jenkins                  | CI/CD automation                 |
| Terraform                | Infrastructure provisioning      |
| Docker                   | Containerization                 |
| Kubernetes               | Container orchestration          |
| Azure Container Registry | Container image registry         |
| Gitleaks                 | Secret detection                 |
| Trivy                    | Container vulnerability scanning |
| Checkov                  | Infrastructure security scanning |
| SonarQube                | Code quality scanning            |
| OWASP ZAP                | Dynamic security testing         |

---

# Infrastructure

Infrastructure is provisioned using **Terraform**.

Resources created:

* Resource Group
* Azure Kubernetes Service (AKS)
* Azure Container Registry (ACR)
* Log Analytics Workspace
* ACR → AKS role assignment

Region used:

```
Canada Central
```

---

# Build Docker Images

Run from project root.

### Frontend

```
docker build -t frontend:v1 -f docker/frontend/Dockerfile .
```

### Backend

```
docker build -t backend:v1 -f docker/backend/Dockerfile .
```

### Worker

```
docker build -t worker:v1 -f docker/worker/Dockerfile .
```

---

# Push Images to Azure Container Registry

Example:

```
docker tag backend:v1 <acr-name>.azurecr.io/backend:v1
docker push <acr-name>.azurecr.io/backend:v1
```

Repeat for:

```
frontend
worker
```

Images are stored in:

```
Azure Container Registry (ACR)
```

---

# Provision Infrastructure with Terraform

Navigate to:

```
infra/terraform/env/dev
```

Initialize Terraform:

```
terraform init
```

Check the plan:

```
terraform plan
```

Apply infrastructure:

```
terraform apply
```

Resources will be created in Azure.

---

# Kubernetes Deployment

Apply Kubernetes manifests.

### Namespace

```
kubectl apply -f kubernetes/namespaces.yaml
```

### Database

```
kubectl apply -f kubernetes/database/
```

### Backend

```
kubectl apply -f kubernetes/backend/
```

### Worker

```
kubectl apply -f kubernetes/worker/
```

### Frontend

```
kubectl apply -f kubernetes/frontend/
```

---

# Verify Deployment

Check nodes:

```
kubectl get nodes
```

Check pods:

```
kubectl get pods -n microservices
```

Check services:

```
kubectl get svc -n microservices
```

---

# Application Access

Frontend is exposed via **LoadBalancer service**.

Example:

```
http://<external-ip>
```

Backend and database are exposed internally using **ClusterIP** services.

---

# Security Scans

Security scans run as part of Jenkins pipelines.

Reports generated inside:

```
security/
├── gitleaks-report.json
└── checkov-report.json
```

Additional scans include:

* Trivy container scan
* SonarQube code scan
* OWASP ZAP dynamic scan

---

# Repository Structure

```
azure-aks-devsecops-platform
│
├── app
│   ├── backend
│   │   ├── app.py
│   │   └── requirements.txt
│   │
│   ├── frontend
│   │   ├── health.html
│   │   └── index.html
│   │
│   └── worker
│       └── worker.py
│
├── docker
│   ├── backend
│   │   └── Dockerfile
│   ├── frontend
│   │   └── Dockerfile
│   └── worker
│       └── Dockerfile
│
├── kubernetes
│   ├── backend
│   ├── database
│   ├── frontend
│   ├── worker
│   └── namespaces.yaml
│
├── infra
│   └── terraform
│       ├── env
│       │   └── dev
│       └── modules
│
├── cicd
│   ├── backend
│   ├── frontend
│   ├── worker
│   ├── database
│   └── terraform
│
├── security
│   ├── gitleaks-report.json
│   └── checkov-report.json
│
├── docs
│   └── screenshots
│
└── README.md
```

---

# Key Skills Demonstrated

* Azure Kubernetes Service (AKS)
* Azure Container Registry (ACR)
* Docker containerization
* Kubernetes deployments and services
* Infrastructure as Code with Terraform
* Jenkins CI/CD pipelines
* DevSecOps security scanning
* Microservices architecture
* Cloud networking and load balancing

---

# Future Improvements

* Helm charts for Kubernetes deployment
* GitOps deployment with ArgoCD
* Monitoring with Prometheus and Grafana
* Azure Key Vault for secret management
* Kubernetes Horizontal Pod Autoscaling
