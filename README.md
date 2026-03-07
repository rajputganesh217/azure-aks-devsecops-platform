# Azure DevSecOps Kubernetes Platform - Proof of Concept

## 1️⃣ Introduction
Welcome to the Azure DevSecOps Kubernetes Platform. This project is a comprehensive **Proof of Concept (POC)** demonstrating a true production-grade DevSecOps architecture on Microsoft Azure. It automates the end-to-end delivery of a microservice application (Frontend, Backend, Worker, PostgreSQL) by integrating Infrastructure as Code (IaC), zero-trust network isolation, and a strict shift-left security pipeline.

The goal of this platform is to prove that modern applications can be delivered rapidly through fully automated Jenkins CI/CD pipelines without compromising on deep, multi-layered security. Every stage of the deployment is gated by professional security scanning tools spanning source code, dependencies, containers, and infrastructure.

## 2️⃣ Architecture Overview
The platform seamlessly blends Azure Cloud Infrastructure with specialized DevSecOps orchestration:
- **Infrastructure Layer**: Fully provisioned via **Terraform**. Establish a secure Hub-and-Spoke Virtual Network, isolated subnets, a Private Azure Kubernetes Service (AKS) cluster, an Azure Container Registry (ACR), and secure Azure Blob Storage for security compliance reporting.
- **Orchestration Layer**: **AKS** handles the container orchestration. It's deployed as a private cluster, meaning its API server is not exposed to the public internet.
- **CI/CD Layer**: **Jenkins** acts as the central orchestrator, executing declarative pipelines that perform building, intensive security scanning, and deployments.
- **Application Layer**: Three custom microservices (Frontend UI, Backend API, asynchronous Worker) and a stateful PostgreSQL database, all deployed continuously into the cluster.

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
The architecture utilizes a deeply isolated VNet design governed by strict Network Security Groups (NSGs):

1. **Public Subnet (`subnet-public`)**
   - Holds public-facing Azure LoadBalancers dynamically created by AKS.
2. **Application Subnet (`subnet-private-app`)**
   - Hosts the AKS Worker Nodes.
   - **Isolation**: Direct internet inbound access is strictly denied (`DenyInternetInbound`).
   - **Health Probes**: Explicitly permits Azure LoadBalancer health probes on NodePort ranges (`30000-32767`).
   - **Ingress**: Explicitly allows HTTP (Port 80) from the internet to the LoadBalancer VIP.
3. **Database Subnet (`subnet-private-db`)**
   - For highly isolated workloads. Only allows connections on Port `5432` originating exclusively from the Application Subnet.

## 5️⃣ Security Implementation
This POC implements a defense-in-depth security posture, categorized by layer:
- **Network Security:** Private AKS Cluster, NSG port-blocking, and isolated VNet tiers.
- **Identity & Access Management (IAM):** 
  - **Zero Hardcoded Secrets**: Application secrets (like database passwords) are stored exclusively in Jenkins Global Credentials and injected at runtime.
  - **RBAC**: Terraform dynamically calculates the CI/CD Service Principal and assigns it `Storage Blob Data Contributor` to upload reports, adhering to the principle of least privilege.
  - **Managed Identities**: AKS nodes natively pull from ACR using Azure Managed Identities, eliminating the need for Docker login credentials inside the cluster.
- **"Shift-Left" Pipeline Gates:** No code reaches the cluster without passing Gitleaks, Checkov, Dependency-Check, SonarQube, and Trivy.

## 6️⃣ CI/CD Pipeline
The deployment relies on Jenkins Declarative Pipelines, tightly separated by concern. All pipelines execute in this general structure:
1. **Source Checkout**
2. **Pre-Build Scan**: `Gitleaks` (Secrets) and `Dependency-Check` (Libraries) or `Checkov` (IaC).
3. **Static Analysis**: `SonarQube` (SAST).
4. **Artifact Build**: Docker image compilation.
5. **Post-Build Scan**: `Trivy` (Container Vulnerabilities).
6. **Artifact Push**: Push secure image to Azure Container Registry.
7. **Deployment**: Uses `az aks command invoke` to securely proxy `kubectl` commands into the *private* AKS cluster without requiring a VPN or jumpbox for the Jenkins agent.
8. **Compliance Archiving**: Re-names, compresses (`tar.gz`), and uploads all security reports directly to Azure Blob Storage inside `app-name/build-number/` hierarchies.

## 7️⃣ Deployment Workflow
For a from-scratch deployment, the sequence is critical to ensure dependencies exist:
1. **Terraform Pipeline (`cicd/terraform/Jenkinsfile`)**: Builds the VNet, ACR, Storage Account, and AKS cluster.
2. **Database Pipeline (`cicd/database/Jenkinsfile`)**: Pulls `postgres:15`, runs a Trivy scan, dynamically creates the `postgres-secret` inside AKS, and deploys the database manifests.
3. **Backend & Worker Pipelines (`cicd/backend/Jenkinsfile`, `cicd/worker/Jenkinsfile`)**: Builds the microservices, connects to Postgres via the injected secret, and applies the deployments securely.
4. **Frontend Pipeline (`cicd/frontend/Jenkinsfile`)**: Builds the UI proxy, provisions the Azure LoadBalancer, and exposes the entry point via Port 80.

## 8️⃣ Monitoring & Logging (Optional)
This architecture is provisioned with an **Azure Log Analytics Workspace** integrated natively into the AKS module. 
- Kubernetes API server audit logs, node metrics, and pod lifecycles are piped into Azure Monitor via Container Insights.
- Security reports generated by the CI/CD pipeline act as persistent audit trails in Blob Storage, independent of the cluster's lifecycle.

## 9️⃣ Disaster Recovery Workflow
Because the entire platform adheres strictly to Infrastructure as Code and Declarative configuration, recovering from a total regional failure or catastrophic cluster loss is trivial:
1. Re-run the **Terraform Pipeline** (points to a new region if necessary).
2. Once the cluster is up, re-run the **Database**, **Backend**, **Worker**, and **Frontend** Jenkins pipelines sequentially.
3. Kubernetes declarative manifests will restore the exact state. Jenkins acts as the source of truth for secret redeployment.

## 🔟 Future Improvements
While this is a robust POC, scaling it to enterprise production could include:
1. **Dynamic Application Security Testing (DAST)**
   - Introduce OWASP ZAP into the end of the Frontend pipeline to scan the live LoadBalancer for XSS and injection flaws.
2. **Azure API Management (APIM)**
   - Place APIM in front of the application subnet to provide rate-limiting, WAF capabilities, and OAuth token validation.
3. **Azure Key Vault CSI Driver**
   - Transition from Jenkins injecting Kubernetes Secrets directly to utilizing the AKS Key Vault CSI driver, allowing pods to mount hardware-backed secrets dynamically as volumes.
4. **Advanced Observability**
   - Deploy a Prometheus and Grafana stack inside the cluster for deep-dive application performance monitoring (APM) and custom alerts.
