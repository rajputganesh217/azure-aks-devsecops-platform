# Azure DevSecOps Kubernetes Platform - Proof of Concept

## 1️⃣ Introduction
Welcome to the Azure DevSecOps Kubernetes Platform. This project is a comprehensive **Proof of Concept (POC)** demonstrating a true production-grade DevSecOps architecture on Microsoft Azure. It automates the end-to-end delivery of a microservice application (Frontend, Backend, Worker, PostgreSQL) by integrating Infrastructure as Code (IaC), zero-trust network isolation, and a strict shift-left security pipeline.

The goal of this platform is to prove that modern applications can be delivered rapidly through fully automated Jenkins CI/CD pipelines without compromising on deep, multi-layered security. Every stage of the deployment is gated by professional security scanning tools spanning source code, dependencies, containers, and infrastructure.

## 2️⃣ Getting Started / Cloning this Repository
If you are cloning this repository to deploy the DevSecOps platform in your own environment, follow these steps.

### Prerequisites
Before running the pipelines, ensure you have the following installed and configured:
- **Azure Account**: Active subscription with permissions to create Resource Groups and Service Principals.
- **Jenkins Server**: A running Jenkins instance (local or clouded) with the following plugins installed:
  - Pipeline, GitHub, Docker Pipeline, SonarQube Scanner.
- **DevSecOps Tools Installed on Jenkins Agent**:
  - `terraform` (CLI), `az` (Azure CLI), `docker`, `trivy`, `checkov`, `gitleaks`, `dependency-check`.
- **SonarQube Server**: A running SonarQube instance accessible by Jenkins.

### Step 1: Clone the Repository
```bash
git clone https://github.com/rajputganesh217/azure-aks-devsecops-platform.git
cd azure-aks-devsecops-platform
```

### Step 2: Configure Jenkins Credentials
Navigate to **Manage Jenkins -> Credentials** and add the following Global Secret Texts:
- **Azure Service Principal**: `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`.
  - *(Note: These same IDs should also be duplicated as exactly `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, etc. for Terraform's azurerm provider)*.
- **Database Secrets**: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.
- **API Keys**: `sonar-token` (SonarQube auth), `NVD_API_KEY` (Dependency-Check), `azure-acr-credentials`.

### Step 3: Execution Execution Flow
In Jenkins, create **five new Pipeline jobs**, pointing each to its respective `Jenkinsfile` in the repository. **You MUST run them in this exact order** the very first time to ensure infrastructure dependencies exist:

1. **`terraform` pipeline** -> (`cicd/terraform/Jenkinsfile`)
   - *Wait for completion. This provisions the Azure VNet, AKS Cluster, and ACR.*
2. **`database` pipeline** -> (`cicd/database/Jenkinsfile`)
   - *Provisions the PostgreSQL Kubernetes deployment and injects the secrets.*
3. **`backend` pipeline** -> (`cicd/backend/Jenkinsfile`)
4. **`worker` pipeline** -> (`cicd/worker/Jenkinsfile`)
5. **`frontend` pipeline** -> (`cicd/frontend/Jenkinsfile`)
   - *Spins up the Azure LoadBalancer. Wait 2-3 minutes after completion for the Public IP to attach.*

Once the frontend finishes, run `kubectl get svc shoe-frontend` to get your public IP, and open it in your browser!

---

## 3️⃣ Architecture Overview
The platform seamlessly blends Azure Cloud Infrastructure with specialized DevSecOps orchestration:
- **Infrastructure Layer**: Fully provisioned via **Terraform**. Establishes a Secure Tiered Virtual Network Architecture, isolated subnets, a Private Azure Kubernetes Service (AKS) cluster, an Azure Container Registry (ACR), and secure Azure Blob Storage for security compliance reporting.
- **Orchestration Layer**: **AKS** handles the container orchestration. It's deployed as a private cluster, meaning its API server is not exposed to the public internet.
- **CI/CD Layer**: **Jenkins** acts as the central orchestrator, executing declarative pipelines that perform building, intensive security scanning, and deployments.
- **Application Layer**: Three custom microservices (Frontend UI, Backend API, asynchronous Worker) and a stateful PostgreSQL database, all deployed continuously into the cluster.

### System Architecture Diagram
```text
                        ┌──────────────────────────┐
                        │          Users           │
                        │  Browser / Client Apps   │
                        └─────────────┬────────────┘
                                      │
                                      │ HTTP
                                      ▼
                         ┌────────────────────────┐
                         │  Azure Public Internet │
                         └─────────────┬──────────┘
                                       │
                                       ▼
                         ┌────────────────────────┐
                         │  Azure Load Balancer   │
                         │  (Public IP :80)       │
                         └─────────────┬──────────┘
                                       │
                                       ▼
                    ┌────────────────────────────────────┐
                    │        Azure Kubernetes Service    │
                    │              (AKS)                 │
                    │                                    │
                    │   ┌────────────────────────────┐   │
                    │   │ Frontend Deployment        │   │
                    │   │ (Nginx / UI)               │   │
                    │   └─────────────┬──────────────┘   │
                    │                 │                  │
                    │                 ▼                  │
                    │   ┌────────────────────────────┐   │
                    │   │ Backend API Deployment     │   │
                    │   │ (Application Service)      │   │
                    │   └─────────────┬──────────────┘   │
                    │                 │                  │
                    │                 ▼                  │
                    │   ┌────────────────────────────┐   │
                    │   │ PostgreSQL Database        │   │
                    │   │ (Stateful Storage)         │   │
                    │   └─────────────┬──────────────┘   │
                    │                 │                  │
                    │                 ▼                  │
                    │   ┌────────────────────────────┐   │
                    │   │ Worker Service             │   │
                    │   │ (Async Processing)         │   │
                    │   └────────────────────────────┘   │
                    │                                    │
                    └────────────────────────────────────┘


            ┌──────────────────────────────────────────────┐
            │                Azure Resources               │
            │                                              │
            │  Azure Container Registry (ACR)              │
            │  Azure Blob Storage (Security Reports)       │
            │  Azure Log Analytics / Monitoring            │
            │  Azure VNet + NSG Network Isolation          │
            └──────────────────────────────────────────────┘
```

## 3️⃣ Technology Stack
| Category | Tool / Technology | Purpose |
| :--- | :--- | :--- |
| **Cloud Provider** | Azure | Core infrastructure hosting |
| **Infrastructure as Code** | Terraform | Reproducible provisioning, networking, and RBAC |
| **Container Engine** | Azure Kubernetes Service (AKS) | Microservice deployment, networking, and scaling |
| **Container Registry** | Azure Container Registry (ACR) | Private, secure repository for compiled Docker images |
| **Artifact Storage** | Azure Blob Storage | Archiving point-in-time security/compliance reports |
| **CI/CD Orchestration** | Jenkins | Pipeline automation, credentials injection |
| **Source Control** | Git / GitHub | Application code and trigger events |
| **Code Quality / SAST** | SonarQube | Deep static source code analysis |
| **Library Security / SCA** | OWASP Dependency-Check | Vulnerability scanning for application libraries |
| **Secret Detection** | Gitleaks | Hardcoded credential detection in git history |
| **Container Security** | Trivy | Final binary, OS artifact, and third-party image scanning |
| **IaC Security** | Checkov | Terraform template scanning |
| **Database** | PostgreSQL | Stateful backend storage |

## 4️⃣ Infrastructure Design
The architecture utilizes a deeply isolated **Secure Tiered Virtual Network Architecture** governed by strict Network Security Groups (NSGs):

### Network Architecture Diagram
```text
Azure VNet
│
├── Public Subnet
│      └── Azure LoadBalancer
│
├── Private App Subnet
│      └── AKS Node Pools
│            ├ Frontend Pods
│            ├ Backend Pods
│            └ Worker Pods
│
└── Database Subnet
       └── PostgreSQL Pod
```

1. **Public Subnet (`subnet-public`)**
   - Holds public-facing Azure LoadBalancers dynamically created by AKS.
2. **Application Subnet (`subnet-private-app`)**
   - Hosts the AKS Worker Nodes.
   - **Isolation**: Direct internet inbound access is strictly denied (`DenyInternetInbound`).
   - **Health Probes**: Explicitly permits Azure LoadBalancer health probes on NodePort ranges (`30000-32767`).
   - **Ingress**: Explicitly allows HTTP (Port 80) from the internet to the LoadBalancer VIP.
3. **Database Subnet (`subnet-private-db`)**
   - For highly isolated workloads. Only allows connections on Port `5432` originating exclusively from the Application Subnet.

## 5️⃣ Kubernetes Deployment Architecture
The workloads running inside the private AKS cluster are structured natively into independent deployments and exposed via specific Kubernetes Services:

```text
AKS Cluster
│
├ Frontend Deployment (2 replicas)
│  └─ Service Type: LoadBalancer (Exposed via Public IP)
│
├ Backend Deployment (2 replicas)
│  └─ Service Type: ClusterIP (Internal only)
│
├ Worker Deployment (1 replica)
│  └─ No Service (Pulls data asynchronously)
│
└ PostgreSQL Deployment (1 pod)
   └─ Service Type: ClusterIP (Internal data access)
```

## 6️⃣ Security Implementation
This POC implements a defense-in-depth security posture, categorized by layer:
- **Network Security:** Private AKS Cluster, NSG port-blocking, and isolated VNet tiers.
- **Identity & Access Management (IAM):** 
  - **Zero Hardcoded Secrets**: Application secrets (like database passwords) are stored exclusively in Jenkins Global Credentials and injected at runtime.
  - **RBAC**: Terraform dynamically calculates the CI/CD Service Principal and assigns it `Storage Blob Data Contributor` to upload reports, adhering to the principle of least privilege.
  - **Managed Identities**: AKS nodes natively pull from ACR using Azure Managed Identities, eliminating the need for Docker login credentials inside the cluster.
- **"Shift-Left" Pipeline Gates:** No code reaches the cluster without passing Gitleaks, Checkov, Dependency-Check, SonarQube, and Trivy.

## 7️⃣ CI/CD Pipeline
The deployment relies on Jenkins Declarative Pipelines, tightly separated by concern. 

### DevSecOps Pipeline Architecture Diagram
```text
                     ┌─────────────────────────┐
                     │       Developer         │
                     │   Git Push / Commit     │
                     └────────────┬────────────┘
                                  │
                                  ▼
                     ┌─────────────────────────┐
                     │        GitHub           │
                     │   Source Code Repo      │
                     └────────────┬────────────┘
                                  │
                                  ▼
                     ┌─────────────────────────┐
                     │        Jenkins          │
                     │     CI/CD Pipeline      │
                     └────────────┬────────────┘
                                  │
               ┌──────────────────┼──────────────────┐
               │                  │                  │
               ▼                  ▼                  ▼

      ┌──────────────┐   ┌────────────────┐   ┌──────────────┐
      │   Gitleaks   │   │ SonarQube SAST │   │ Dependency   │
      │ Secret Scan  │   │ Code Analysis  │   │ Check (SCA)  │
      └──────┬───────┘   └────────┬───────┘   └──────┬───────┘
             │                    │                 │
             └────────────┬───────┴─────────────────┘
                          ▼
                 ┌───────────────────┐
                 │   Docker Build    │
                 │  Application Image│
                 └──────────┬────────┘
                            ▼
                     ┌──────────────┐
                     │   Trivy Scan │
                     │ Container CVE│
                     └──────┬───────┘
                            ▼
               ┌─────────────────────────┐
               │ Azure Container Registry│
               │          (ACR)          │
               └────────────┬────────────┘
                            ▼
               ┌─────────────────────────┐
               │   AKS Deployment        │
               │ az aks command invoke   │
               └────────────┬────────────┘
                            ▼
               ┌─────────────────────────┐
               │  Kubernetes Cluster     │
               │ Frontend / Backend / DB │
               └────────────┬────────────┘
                            ▼
               ┌─────────────────────────┐
               │ Azure Blob Storage      │
               │ Security Reports Archive│
               └─────────────────────────┘
```

All application pipelines execute in this general structure:
1. **Source Checkout**
2. **Pre-Build Scan**: `Gitleaks` (Secrets) and `Dependency-Check` (Libraries) or `Checkov` (IaC).
3. **Static Analysis**: `SonarQube` (SAST).
4. **Artifact Build**: Docker image compilation.
5. **Post-Build Scan**: `Trivy` (Container Vulnerabilities).
6. **Artifact Push**: Push secure image to Azure Container Registry.
7. **Deployment**: Uses `az aks command invoke` to securely proxy `kubectl` commands into the *private* AKS cluster without requiring a VPN or jumpbox for the Jenkins agent.
8. **Compliance Archiving**: Re-names, compresses (`tar.gz`), and uploads all security reports directly to Azure Blob Storage inside `app-name/build-number/` hierarchies.

## 8️⃣ Deployment Workflow
For a from-scratch deployment, the sequence is critical to ensure dependencies exist:
1. **Terraform Pipeline (`cicd/terraform/Jenkinsfile`)**: Builds the VNet, ACR, Storage Account, and AKS cluster.
2. **Database Pipeline (`cicd/database/Jenkinsfile`)**: Pulls `postgres:15`, runs a Trivy scan, dynamically creates the `postgres-secret` inside AKS, and deploys the database manifests.
3. **Backend & Worker Pipelines (`cicd/backend/Jenkinsfile`, `cicd/worker/Jenkinsfile`)**: Builds the microservices, connects to Postgres via the injected secret, and applies the deployments securely.
4. **Frontend Pipeline (`cicd/frontend/Jenkinsfile`)**: Builds the UI proxy, provisions the Azure LoadBalancer, and exposes the entry point via Port 80.

## 9️⃣ Monitoring & Logging (Optional)
This architecture is provisioned with an **Azure Log Analytics Workspace** integrated natively into the AKS module. 
- Kubernetes API server audit logs, node metrics, and pod lifecycles are piped into Azure Monitor via Container Insights.
- Security reports generated by the CI/CD pipeline act as persistent audit trails in Blob Storage, independent of the cluster's lifecycle.

## 🔟 Disaster Recovery Workflow
Because the entire platform adheres strictly to Infrastructure as Code and Declarative configuration, recovering from a total regional failure or catastrophic cluster loss is trivial:
1. Re-run the **Terraform Pipeline** (points to a new region if necessary).
2. Once the cluster is up, re-run the **Database**, **Backend**, **Worker**, and **Frontend** Jenkins pipelines sequentially.
3. Kubernetes declarative manifests will restore the exact state. Jenkins acts as the source of truth for secret redeployment.

## 🏆 Key Engineering Achievements
* Designed a **secure DevSecOps pipeline on Azure AKS** utilizing private clusters and isolated worker nodes.
* Implemented **multi-layer security scanning (SAST, SCA, container scanning, secret detection)** directly into CI/CD gates.
* Built **fully automated infrastructure provisioning using Terraform (IaC)**.
* Integrated **Azure RBAC and Managed Identities** for zero-trust, secretless integrations between Azure services.
* Implemented a **secure tiered virtual network architecture with tight NSG isolation**.
* Automated **artifact and compliance security report archival in Azure Blob Storage** for historical auditing.

## 🚀 Future Improvements
While this is a robust POC, scaling it to enterprise production could include:
1. **Dynamic Application Security Testing (DAST)**: Introduce OWASP ZAP into the end of the Frontend pipeline to scan the live LoadBalancer for XSS and injection flaws.
2. **Azure API Management (APIM)**: Place APIM in front of the application subnet to provide rate-limiting, WAF capabilities, and OAuth token validation.
3. **Azure Key Vault CSI Driver**: Transition from Jenkins injecting Kubernetes Secrets directly to utilizing the AKS Key Vault CSI driver, allowing pods to mount hardware-backed secrets dynamically as volumes.
4. **Advanced Observability**: Deploy a Prometheus and Grafana stack inside the cluster for deep-dive application performance monitoring (APM) and custom alerts.
