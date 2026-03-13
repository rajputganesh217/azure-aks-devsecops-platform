# 🛡️ Enterprise Azure DevSecOps Kubernetes Platform

![Platform](https://img.shields.io/badge/Platform-Azure-blue.svg)
![Orchestration](https://img.shields.io/badge/Orchestration-Kubernetes_AKS-326ce5.svg)
![IaC](https://img.shields.io/badge/IaC-Terraform-623CE4.svg)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-D24939.svg)
![Security](https://img.shields.io/badge/Security-Shift--Left-success.svg)

Welcome to the **Enterprise Azure DevSecOps Platform**. This project represents a state-of-the-art, production-grade implementation of a fully automated DevSecOps ecosystem. It bridges the gap between rapid software delivery and uncompromising security by embedding compliance, vulnerability management, and infrastructure as code (IaC) directly into the heart of the SDLC.

Utilizing **Jenkins** for orchestration, **Terraform** for immutable infrastructure, and a suite of specialized security scanners (**Gitleaks, Checkov, Trivy, Dependency-Check**), this platform deploys a multi-tier microservices application into a highly secured, private **Azure Kubernetes Service (AKS)** environment.

## 📑 Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Universal Architecture Diagram](#2-universal-architecture-diagram)
3. [Deep-Dive: The DevSecOps CI/CD Pipeline](#3-the-devsecops-cicd-pipeline)
4. [Application Traffic Flow & Security Layers](#4-application-traffic-flow)
5. [Enterprise Security & Zero-Trust Architecture](#5-security--zero-trust-architecture)
6. [Infrastructure as Code (Terraform Modularity)](#6-infrastructure-as-code-terraform)
7. [Comprehensive Repository Structure](#7-repository-structure)
8. [Deployment & Operational Guide](#8-step-by-step-deployment-guide)
9. [Cost Management & FinOps Strategy](#9-cost-management--finops)
10. [Future Roadmap & Advanced Capability](#10-future-roadmap-100-private-infra)

---

## 1. Executive Summary

### The Legacy IT Challenge
In traditional "Water-fall" or siloed Agile models, organizations suffer from the **"Wall of Confusion"**. Developers focus on speed, while Operations focuses on stability, and Security focuses on risk. This fragmentation leads to:
*   **Late-Stage Security Discoveries:** Vulnerabilities found right before launch cause delays and high remediation costs.
*   **Manual Configuration Drift:** Environments (Dev, QA, Prod) slowly diverge, leading to "it works on my machine" failures.
*   **Insecure Secrets Handling:** Hardcoded credentials and non-rotated keys create massive attack vectors.
*   **Disaster Recovery Friction:** Rebuilding a complex cloud environment manually takes days of effort and is prone to human error.

### The DevSecOps Solution (The "Three Ways")
This platform implements the core pillars of DevSecOps to eliminate these bottlenecks:
1.  **Flow (Left to Right):** Automation of the entire build-to-deploy process ensures that features reach users in minutes.
2.  **Feedback (Right to Left):** Quality and security gates provide instant feedback to developers, allowing for "Shift-Left" remediation.
3.  **Continuous Learning:** Immutable infrastructure and comprehensive audit logs allow for forensic analysis and constant system improvement.

**Key Values:**
*   **Infrastructure as Code (IaC):** 100% of Azure resources are defined in Terraform, enabling idempotent deployments and disaster recovery in <15 minutes.
*   **Security Gates:** Five distinct security scanners intercept vulnerabilities before they ever reach a container registry.
*   **Immutable Artifacts:** Using Git Commit Hashes as tags across all environments ensures that what was tested in QA is *exactly* what runs in Prod.

---

## 2. Universal Architecture Diagram

This diagram illustrates the multi-tier cloud topology. It highlights the separation of concerns between the Public Internet, Edge Security (WAF), Private Networking, and Managed PaaS services.

```mermaid
flowchart TB
    %% Define External Entities
    Users(["🌐 End Users\n(External)"])
    Devs(["💻 DevOps Engineers\n(Jenkins/Git)"])
    
    %% Define Azure Cloud Boundary
    subgraph AzureCloud ["☁️ Microsoft Azure Cloud (Region: eastus)"]
        direction TB
        
        %% Edge Services
        subgraph EdgeLayer ["🛡️ Edge Security Layer"]
            AppGW["Azure Application Gateway v2\n(WAF, TLS Termination,\nStatic Public IP)"]
        end
        
        %% Virtual Network
        subgraph VNet ["🔒 Virtual Network (Address Space: 10.1.0.0/16)"]
            direction TB
            
            subgraph PublicSubnet ["🌐 Public/Gateway Subnet"]
                AGIC("⚙️ AGIC Pod\n(Ingress Controller)")
            end
            
            subgraph JumpSubnet ["🛡️ Bastion/Jump Subnet"]
                JumpServer["🖥️ Management Jump Server\n(Restricted SSH, Admin Tools)"]
            end
            
            subgraph AKSSubnet ["☸️ AKS Private Application Subnet"]
                direction TB
                AKS_API["AKS Control Plane\n(Private Endpoint)"]
                
                subgraph AppNamespaces ["K8s Namespaces (Dev/QA/Prod)"]
                    direction TB
                    subgraph Microservices ["Pod Topology"]
                        FE["⚛️ Frontend\n(Nginx/React)"]
                        BE["🐍 Backend API\n(Python/Flask)"]
                        WK["⚙️ Worker Service\n(Python)"]
                    end
                end
                
                AKS_API --- AppNamespaces
            end
            
            subgraph DBSubnet ["🗄️ Database Private Subnet"]
                DB[("🐘 Azure PostgreSQL\n(Flexible Server)")]
                DB_DNS["Private DNS Zone\n(postgres.database.azure.com)"]
            end
        end
        
        %% Azure PaaS Services
        subgraph PaaS ["💎 Managed Security & Data Services"]
            direction LR
            ACR[("🐳 Container Registry\n(ACR)")]
            KV[("🗝️ Key Vault\n(Secrets/CSI)")]
            LAW[("📊 Log Analytics\n(Insights)")]
            Blob[("📁 Storage Account\n(Security Audits)")]
        end
    end
    
    %% Define CI/CD
    subgraph Toolchain ["🤵 CI/CD Orchestration (Jenkins)"]
        Jenkins(("Jenkins Master\n(Controller)"))
        J_Nodes("Build Nodes\n(Docker, Terraform, Trivy)")
    end

    %% Routing Flow
    Users ==>|HTTPS/443| AppGW
    AppGW ==>|Clean Scanned Traffic| AGIC
    AGIC ==>|K8s Ingress Path| FE
    FE -.->|Internal ClusterIP| BE
    BE -.->|Redis/RabbitMQ (Planned)| WK
    BE -.->|VNet Peering/Private Link| DB
    
    %% CI/CD & Admin Flow
    Devs -->|Git Commit| Jenkins
    Jenkins -->|1. Build & Security Scan| J_Nodes
    J_Nodes -->|2. Push Scanned Image| ACR
    J_Nodes -->|3. SSH Management| JumpServer
    JumpServer -->|4. Deploy Manifests| AKS_API
    Jenkins -->|5. Archive Proof| Blob
    
    %% Identity & Secrets
    AKS_API -.->|Managed Identity| ACR
    AppNamespaces -.->|CSI Driver Mounting| KV
    AppNamespaces -.->|Diagnostic Settings| LAW
```

---

## 3. Deep-Dive: The DevSecOps CI/CD Pipeline

Our pipeline is built on the principle of **Continuous Security**. Every build triggered in Jenkins follows a rigorous 8-stage gate system. If any gate fails (e.g., a critical vulnerability is found), the pipeline is **terminated immediately**, preventing insecure code from reaching Azure.

| Stage | Tool | Description |
| :--- | :--- | :--- |
| **1. Pre-Build Analysis** | **Gitleaks** | Scans the entire Git history for high-entropy strings, regex matches for Azure/AWS keys, and common password patterns. |
| **2. Code Quality (SAST)** | **SonarQube** | Analyzes source code logic to find "Code Smells," bugs, and security hotspots (e.g., unsanitized inputs). |
| **3. Dependency Scan (SCA)** | **Dependency-Check** | Cross-references `requirements.txt` and `package.json` against the **NVD (National Vulnerability Database)** to find vulnerable 3rd-party libs. |
| **4. Infra Scanning** | **Checkov** | Evaluates Terraform HCL files against 1000+ best-practice policies (e.g., ensuring "Public Access" is disabled on Storage). |
| **5. Containerization** | **Docker** | Builds multi-stage, non-root Docker images to minimize the attack surface of the final artifact. |
| **6. Image Scanning** | **Trivy** | Performs a deep binary scan of the Docker image layers and OS packages (Alpine/Debian) for known CVEs. |
| **7. Secure Deployment** | **SSH / Kubectl** | Uses a secure Jump Server as a "Proxy" to reach the private AKS API, ensuring no direct public access to the control plane. |
| **8. Compliance Audit** | **Azure Blob** | Automatically uploads JSON/HTML reports of all scans to a centralized storage account for long-term audit trail. |

---

## 4. Application Traffic Flow & Security Layers

1.  **Edge Ingress:** External users resolve `frontend.microservices.local` to the **Azure Application Gateway** Static Public IP.
2.  **WAF Filtering:** The Application Gateway (utilizing OWASP Core Rule Set) inspects traffic for SQLi, XSS, and Protocol violations.
3.  **AGIC Routing:** The **Application Gateway Ingress Controller (AGIC)** pod in AKS synchronizes K8s Ingress rules with the Gateway, routing traffic to the internal `frontend` service.
4.  **Service Resolution:** Traffic reaches the **Frontend Pods** (Nginx-unprivileged).
5.  **Inter-Service Comm:** The Frontend calls the **Backend API** via internal Kubernetes DNS (`backend.dev.svc.cluster.local`) using **ClusterIP**.
6.  **Background Processing:** The Backend sends intensive tasks (e.g., report generation) to the **Worker Pod** via an internal task queue.
7.  **Data Persistence:** The Backend reads/writes to the **Azure PostgreSQL Flexible Server**. This server is locked to a private subnet via **VNet Injection**, meaning it is physically unreachable from the internet.

---

## 5. Enterprise Security & Zero-Trust Architecture

*   **Network Isolation:** We utilize a 3-tier subnet architecture:
    *   **Gateway Subnet:** Public-facing, limited to App Gateway.
    *   **Application Subnet:** Private, contains AKS Nodes. Denies all inbound except from the Gateway Subnet.
    *   **Database Subnet:** Private, restricted to inbound traffic from the Application Subnet only.
*   **Secret Management:** **Direct injection via CSI**. No secrets are stored as K8s Secrets or Env vars in Git. All passwords (DB, API Keys) are stored in **Azure Key Vault**. The **Azure Key Vault Secrets Store CSI Driver** mounts these secrets as a temporary volume inside the Pods at runtime.
*   **Identity (RBAC):** We use **User-Assigned Managed Identities**. The AKS cluster is granted the `AcrPull` role on the registry and `Key Vault Secrets User` on the vault, eliminating the need for service principal keys inside the cluster.
*   **Static IP Stability:** Public IPs for the App Gateway and Jump Server are "Eternal" (managed outside the main cluster lifecycle) to ensure DNS records remain valid even during a full platform teardown and rebuild.

---

## 6. Infrastructure as Code (Terraform Modularity)

The environment is built using highly reusable, encapsulated modules:
*   `vnet`: Configures Address Spaces, Subnets, and Peering.
*   `aks`: Provisions the Private Cluster, Node Pools, and Managed Identity.
*   `app_gateway`: Sets up the L7 Load Balancer, WAF policies, and AGIC integration.
*   `db`: Deploys PostgreSQL Flexible Server with Private DNS zone integration.
*   `keyvault`: Configures the secure vault with RBAC-based access policies.
*   `jump_server`: Provisions an Ubuntu Bastion host with fixed networking for CI/CD access.

---

## 7. Comprehensive Repository Structure

```text
.
├── app/                        # Application Source Code
│   ├── frontend/               # React/Nginx Frontend
│   └── backend/                # Python/Flask API
├── cicd/                       # Jenkins Pipeline Definitions
│   ├── terraform/              # Infra Provisioning Pipeline
│   ├── frontend/               # Frontend CI/CD
│   ├── backend/                # Backend CI/CD
│   └── worker/                 # Worker CI/CD
├── infra/                      # Infrastructure as Code
│   └── terraform/
│       ├── env/core/           # Environment-specific tfvars & backend config
│       └── modules/            # Reusable Azure Resource Modules (AKS, VNet, etc.)
├── kubernetes/                 # K8s Manifests (YAML)
│   ├── frontend/               # Deployments, Services, Ingress
│   ├── backend/                # API Workloads
│   └── network-policies.yaml   # Zero-Trust Pod Networking Rules
├── security/                   # Security Configuration
│   ├── configs/                # Gitleaks, Checkov, Trivy config files
│   └── reports/                # (Generated) Local cache for security audits
└── docker/                     # Dockerfiles for all microservices
```

---

## 8. Step-by-Step Deployment Guide

### Prerequisites
1.  **Azure Service Principal:** With `Contributor` access at the subscription level.
2.  **Jenkins Server:** Equipped with `az`, `terraform`, `docker`, and `ssh`.
3.  **Storage Account:** To host the Terraform Backend State (`terraform.tfstate`).

### Execution Flow
1.  **Provision Infra:** Run the `cicd/terraform/Jenkinsfile`. This builds the entire Azure network and AKS cluster.
2.  **Configure Bastion:** Retrieve the Jump Server IP and add it to Jenkins `jump-server-ssh` credentials.
3.  **Deploy Database:** Run `cicd/database/Jenkinsfile` to initialize the PostgreSQL server and create the Private DNS links.
4.  **Deploy Apps:** Execute the Backend, Worker, and Frontend pipelines in that order.

---

## 9. Cost Management & FinOps Strategy

*   **Standard_D2s_v3 Nodes:** Balanced compute/memory ratio to minimize "Slack" (unused resources).
*   **Node Auto-Scaling:** (Planned) Scales to zero nodes during off-hours for Dev/QA.
*   **Resource Quotas:** Every Pod is capped at **20m CPU** and **64Mi RAM**, allowing us to run 50+ containers on a single small VM.
*   **Ephemeral Lifecycle:** Using `terraform destroy` via Jenkins, we can wipe non-production environments daily to save up to **72% on compute costs** compared to 24/7 uptime.

---

## 10. Future Roadmap & Advanced Capability

*   **[ ] Service Mesh (Istio):** To provide mutual TLS (mTLS) encryption for pod-to-pod communication.
*   **[ ] GitOps (ArgoCD):** Shift from Jenkins "Push" to ArgoCD "Pull" for higher deployment reliability.
*   **[ ] DAST Integration:** Adding OWASP ZAP to scan the running application in QA for session management and auth flaws.
*   **[ ] Multi-Region Failover:** Terraform expansion to support active-passive disaster recovery across Azure Regions.
