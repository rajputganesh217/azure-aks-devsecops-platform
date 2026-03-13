# 🛡️ Enterprise Azure DevSecOps Kubernetes Platform

![Platform](https://img.shields.io/badge/Platform-Azure-blue.svg)
![Orchestration](https://img.shields.io/badge/Orchestration-Kubernetes_AKS-326ce5.svg)
![IaC](https://img.shields.io/badge/IaC-Terraform-623CE4.svg)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-D24939.svg)
![Security](https://img.shields.io/badge/Security-Shift--Left-success.svg)

Welcome to the **Enterprise Azure DevSecOps Platform**. This project demonstrates a production-ready, fully automated DevSecOps pipeline deploying a multi-tier microservices application to Azure Kubernetes Service (AKS). It utilizes Jenkins for CI/CD, Terraform for immutable Infrastructure as Code (IaC), and integrates rigorous, automated security scanning at every step of the software development lifecycle (SDLC).

## 📑 Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Universal Architecture Diagram](#2-universal-architecture-diagram)
3. [The DevSecOps CI/CD Pipeline](#3-the-devsecops-cicd-pipeline)
4. [Application Traffic Flow](#4-application-traffic-flow)
5. [Security & Zero-Trust Architecture](#5-security--zero-trust-architecture)
6. [Infrastructure as Code (Terraform)](#6-infrastructure-as-code-terraform)
7. [Repository Structure](#7-repository-structure)
8. [Step-by-Step Deployment Guide](#8-step-by-step-deployment-guide)
9. [Cost Management & FinOps](#9-cost-management--finops)
10. [Future Roadmap (100% Private Infra)](#10-future-roadmap-100-private-infra)

---

## 1. Executive Summary

### The Legacy IT Challenge
In traditional SDLC models, organizations operate in silos. Developers write code, Operations manually configure servers, and Security audits the system months later. This results in massive friction, delayed releases, "it works on my machine" syndromes, and chaotic last-minute security rewrites. 

### The DevSecOps Solution
This platform was engineered from the ground up to solve these problems by integrating Development, Security, and Operations into a single automated pipeline:
* **Infrastructure as Code (IaC):** Every network, server, firewall, and database is defined in code, allowing for rapid, error-free disaster recovery.
* **Security Shift-Left:** We scan code, dependencies, infrastructure, and containers proactively during the build process—long before production.
* **Immutable Deployments:** Applications are packaged into standardized Docker containers to guarantee identical execution across Dev, QA, and Prod.

---

## 2. Universal Architecture Diagram

This diagram illustrates the complete, high-level cloud topology, showing how end-users, CI/CD automation, and Azure Managed Services interact.

```mermaid
flowchart TB
    %% Define External Entities
    Users(["🌐 End Users"])
    Devs(["💻 Developers"])
    
    %% Define Azure Cloud Boundary
    subgraph AzureCloud ["☁️ Microsoft Azure Cloud (eastus)"]
        direction TB
        
        %% Edge Services
        AppGW["🛡️ Application Gateway\n(WAF & Static Public IP)"]
        
        %% Virtual Network
        subgraph VNet ["🔒 Virtual Network (10.1.0.0/16)"]
            direction TB
            
            subgraph PublicSubnet ["Public Subnet (AppGW)"]
                AGIC("⚙️ AGIC (Ingress Controller)")
            end
            
            subgraph JumpSubnet ["Jump Server Subnet"]
                JumpServer["🖥️ Jump Server / Bastion\n(Static IP / SSH)"]
            end
            
            subgraph AKSSubnet ["AKS Private Subnet"]
                direction TB
                AKS["☸️ Azure Kubernetes Service (AKS)"]
                
                subgraph Pods ["Microservices"]
                    FE("⚛️ Frontend (React)")
                    BE("🐍 Backend (Python)")
                    WK("⚙️ Worker (Python)")
                end
                
                AKS --- Pods
            end
            
            subgraph DBSubnet ["Database Subnet"]
                DB[("🐘 Azure DB for PostgreSQL\n(Flexible Server)")]
            end
        end
        
        %% Azure PaaS Services
        subgraph PaaS ["Azure Managed Services (PaaS)"]
            ACR[("🐳 Azure Container Registry")]
            KV[("🗝️ Azure Key Vault")]
            LAW[("📊 Log Analytics Workspace")]
            Blob[("📁 Blob Storage (Audit Reports)")]
        end
    end
    
    %% Define CI/CD
    subgraph Toolchain ["CI/CD Toolchain"]
        Jenkins(("🤵 Jenkins CI/CD"))
    end

    %% Routing Flow
    Users ==>|HTTP/HTTPS\nPort 80/443| AppGW
    AppGW ==>|Clean Traffic| AGIC
    AGIC ==>|Route by Path| FE
    FE -.->|ClusterIP| BE
    BE -.->|Async Jobs| WK
    BE -.->|Read/Write| DB
    
    %% CI/CD Flow
    Devs -->|Git Push| Jenkins
    Jenkins -->|1. Build & Push Image| ACR
    Jenkins -->|2. SSH Deploy| JumpServer
    JumpServer -->|3. Kubectl Apply| AKS
    Jenkins -->|4. Upload Security Scans| Blob
    
    %% PaaS Interactions
    AKS -.->|Pull Images (Managed Identity)| ACR
    AKS -.->|Mount Secrets (CSI Driver)| KV
    AKS -.->|Send Metrics/Logs| LAW
```

---

## 3. The DevSecOps CI/CD Pipeline

Our pipeline is built on the principle of **Continuous Security**. Every build triggered in Jenkins follows a rigorous 8-stage gate system:

1. **Pre-Build (Static Analysis):**
    *   **Gitleaks:** Scans the codebase for hardcoded secrets/keys.
    *   **SonarQube:** (Planned) Checks for code quality and maintainability.
2. **Software Composition Analysis (SCA):**
    *   **Dependency-Check:** Scans `requirements.txt` and `package.json` for known CVE vulnerabilities in 3rd-party libraries.
3. **Infrastructure Scanning:**
    *   **Checkov:** Scans Terraform files for cloud misconfigurations (e.g., open NSGs, unencrypted disks).
4. **Containerization:**
    *   Building optimized, non-root Docker images.
5. **Image Scanning:**
    *   **Trivy:** Scans the final Docker image for OS-level vulnerabilities before pushing to ACR.
6. **Immutable Versioning:**
    *   Images are tagged with the specific Git Commit Hash and Environment name to ensure traceability.
7. **Secure Deployment:**
    *   Deploy artifacts are pushed via a secure Jump Server using SSH to prevent direct external access to the AKS API server.
8. **Audit Logging:**
    *   All security scan results are automatically archived to **Azure Blob Storage** for compliance auditing.

---

## 4. Application Traffic Flow

1.  **Ingress:** External users hit the **Azure Application Gateway** IP.
2.  **Security Filtering:** The Application Gateway (running WAF) filters for SQL injection, XSS, and other threats.
3.  **Routing:** Traffic is handed off to **AGIC (Application Gateway Ingress Controller)** inside AKS.
4.  **Service Resolution:** Traffic reaches the **Frontend Pods**.
5.  **Inter-Service Comm:** The Frontend communicates with the **Backend API** via internal Kubernetes Service IPs (ClusterIP).
6.  **Background Processing:** Long-running tasks are sent asynchronously to the **Worker Pod**.
7.  **Data Persistence:** The Backend reads/writes to the **Azure PostgreSQL Flexible Server** sitting in a dedicated private subnet.

---

## 5. Security & Zero-Trust Architecture

*   **Network Isolation:** 3-tier subnet architecture (Public, Application, Database) with strictly defined Network Security Groups (NSGs).
*   **Secret Management:** No secrets are stored in Git. All passwords and keys are stored in **Azure Key Vault** and injected into Pods at runtime using the **Azure Key Vault Secrets Store CSI Driver**.
*   **Static IPs:** Infrastructure uses fixed, reserved Public IPs (Eternals) to ensure reliable access for DNS and CI/CD agents.
*   **Least Privilege:** All Azure resources use **Managed Identities** and RBAC rather than shared access keys.

---

## 6. Infrastructure as Code (Terraform)

The entire environment is modularized:
*   `vnet`: Virtual Networking and Subnets.
*   `aks`: Managed Kubernetes Cluster definition.
*   `app_gateway`: Layer-7 Load Balancer and WAF.
*   `db`: PostgreSQL Flexible Server.
*   `keyvault`: Centralized secret management.
*   `jump_server`: Secure management entry point.

---

## 7. Cost Management & FinOps

*   **Right-Sizing:** Nodes use `Standard_D2s_v3` instances optimized for cost-to-performance in dev environments.
*   **Disposable Environments:** The automation allows for `terraform destroy` on weekends and `terraform apply` on Mondays to save up to 30% on cloud bills.
*   **Shared Resources:** Single ACR and Key Vault shared across microservices to minimize base fixed costs.
