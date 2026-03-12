# Azure DevSecOps Kubernetes Platform

Hey everyone. This is a DevSecOps project I built to show how to deploy a standard microservices app to Azure AKS securely. It uses Jenkins for CI/CD, Terraform for the infrastructure, and integrates security scanning at every step of the pipeline.

The main idea here is to not just push code, but to make sure it's actually secure before it ever hits the cluster. We do secret scanning, static code analysis, library checks, and container scanning in the pipeline before the image even gets to Azure.

## Architecture Overview

This platform demonstrates a secure DevSecOps pipeline deploying a microservices application to Azure Kubernetes Service.

The architecture consists of:
- Jenkins-driven CI/CD pipelines
- Multi-stage security scanning
- Containerized microservices deployed to AKS
- Azure Container Registry for image storage
- Azure Blob Storage for security audit reports
- Network isolation using a tiered Azure Virtual Network

## Project Highlights

- Fully automated DevSecOps pipeline on Azure AKS
- Integrated security scanning across code, dependencies, containers, and infrastructure
- Terraform-based Infrastructure as Code for reproducible environments
- Secure container delivery using Azure Container Registry
- Network isolation using Azure VNet and NSGs
- Security report archiving to Azure Blob Storage for auditability

---

## Getting Started

If you want to spin this up yourself, here is how.

### What You Need

* An **Azure Account** with permissions to create stuff (Resource Groups, Service Principals).
* A **Jenkins Server**. You can run this locally or in the cloud. You'll need plugins like Pipeline, Docker, and SonarQube Scanner.
* Put these tools on your Jenkins agent: `terraform`, `az`, `docker`, `trivy`, `checkov`, `gitleaks`, `dependency-check`.
* A **SonarQube Server** running somewhere that Jenkins can reach.

### How to Run It

1. **Clone it:**
   ```bash
   git clone https://github.com/rajputganesh217/azure-aks-devsecops-platform.git
   cd azure-aks-devsecops-platform
   ```

2. **Jump Server Setup (Prerequisites):**
   This project uses a Jump Server (Bastion) to securely deploy to AKS. 
   - Create a Linux Virtual Machine in the same VNet as AKS (or with VNet peering).
   - Install `kubectl` and `docker` on the Jump Server.
   - Ensure the Jenkins agent has SSH access to the Jump Server.
   - Add the following credentials to Jenkins:
     - `jump-server-ssh`: SSH Private Key for the Jump Server.
     - `JUMP_SERVER_IP`: Public or Private IP of the Jump Server.

3. **Set up your Jenkins Credentials:**
   Go to Manage Jenkins -> Credentials and add these as Secret Texts:
   * **Azure credentials**: `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`. (Also add them as `ARM_...` for Terraform to pick them up).
   * **Database credentials**: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.
   * **API Keys**: `sonar-token`, `NVD_API_KEY`, `azure-acr-credentials`.
   * **Networking**: `JUMP_SERVER_IP`.

4. **Run the Pipelines:**
   You have to run these in order the first time:

   * First, run `cicd/terraform/Jenkinsfile`. (Sets up the VNet, AKS, and ACR).
   * Second, run `cicd/database/Jenkinsfile`. (Sets up the database and project secrets).
   * Third, run `cicd/backend/Jenkinsfile` (Environment: `dev`).
   * Fourth, run `cicd/worker/Jenkinsfile` (Environment: `dev`).
   * Fifth, run `cicd/frontend/Jenkinsfile` (Environment: `dev`).

Wait a few minutes after the frontend pipeline finishes, run `kubectl get svc shoe-frontend` to grab your public IP, and you're good to go!

---

## 1. Image Tagging & Promotion Strategy

We follow a standardized tagging convention and a multi-environment promotion strategy to ensure reliability.

### Tagging Convention
Images are tagged in the format: `{service-name}-{environment}-{8-digit-commit-hash}`
Example: `frontend-dev-abcdef12`

### Promotion Flow
1. **DEV**: Developers push code, triggered by a webhook. Images are built and tagged for `dev`.
2. **QA**: Triggered manually from the pipeline with a `PROMOTE_COMMIT_ID`. It pulls the `dev` tag, retags it for `qa`, and deploys.
3. **UAT/PROD**: Follows the same pattern, pulling from the previous environment's tag (`qa` -> `uat` -> `prod`).

This ensures that the exact same image that was tested in QA is promoted to Production.

---

## 2. CI/CD Pipeline Flow

Here is what happens when code gets pushed. We use Jenkins declarative pipelines to run everything via a **Jump Server** for secure cluster access.

```mermaid
flowchart TD
    Devs("Developers") -->|1. Git Push| GitHub("GitHub Repo")
    GitHub -->|2. Webhook| Jenkins{"Jenkins CI/CD"}
    
    subgraph Scans ["Security Gates"]
        direction LR
        Gitleaks("Gitleaks (Secrets)")
        Sonar("SonarQube (SAST)")
        DepCheck("Dependency-Check (SCA)")
    end
    
    Jenkins ==>|3. Run Scans| Scans
    Jenkins ==>|4. Docker Build| DockerBuild("Docker Build")
    DockerBuild ==>|5. Push Image| ACR("Azure Container Registry")
    Jenkins ==>|6. Deploy| Jump("Jump Server")
    Jump ==>|7. Kubectl Apply| AKS("AKS Cluster")
    ACR -.->|8. AKS Pulls Image| AKS
```

1. **Scans**: We scan for secrets, code quality, and dependency vulnerabilities.
2. **Build**: Docker image is built and tagged with the standardized format.
3. **Push**: Image is pushed to Azure Container Registry.
4. **Deploy**: Jenkins connects to a **Jump Server** via SSH.
5. **Update**: The Jump Server executes `kubectl` commands to update the AKS deployment using the new image tag.


1. **Scans**: We scan the code for hardcoded secrets (`Gitleaks`), bad dependencies (`Dependency-Check`), and code quality (`SonarQube`).
2. **Build**: Docker image is built and tagged using the `service-env-hash` format.
3. **Push**: Image is pushed to Azure Container Registry (ACR).
4. **Deploy**: Jenkins connects to the **Jump Server** and executes the deployment.
5. **Verify**: AKS pulls the new image from ACR and updates the pods.

---

## 2. Infrastructure Architecture

I used Terraform to stand up the Azure networking and clustering. I kept the PaaS stuff outside the VNet and locked down the subnets inside the VNet.

```mermaid
flowchart TD
    subgraph PaaS ["Azure PaaS"]
        direction LR
        ACR("Container Registry")
        Blob("Blob Storage")
    end

    subgraph Azure ["Azure Cloud"]
        direction TB
        ALB["Load Balancer (Public IP)"]
        
        subgraph VNet ["Tiered Virtual Network"]
            direction TB
            subgraph AppSubnet ["App Subnet"]
                AKS("AKS Private Cluster")
            end
            
            subgraph DBSubnet ["Database Subnet (Reserved)"]
                FutureDB("Future: Managed Postgres")
            end
        end
    end

    Users("Users") ===>|Port 80| ALB
    ALB ===>|Traffic Routing| AKS
    PaaS -.->|Images & Reports| AKS
```

* **Public Exposure:** Azure LoadBalancer created by AKS provides the public entry point.
* **App Subnet:** Where the actual AKS worker nodes live. No direct internet access allowed. Standard NSG isolation blocks it off. We explicitly allow the Azure Loadbalancer health probes to talk to the NodePorts.
* **DB Subnet:** Empty for now, but reserved for a future managed Azure DB instance.

---

## 3. Kubernetes Setup

Inside the cluster, here is how the workloads are laid out. The key thing here is that the database is running as a pod strictly internally, meaning you can't hit it from the internet at all.

```mermaid
flowchart TD
    subgraph Azure ["Azure"]
        ALB["Azure Load Balancer"]
        ACR("Container Registry")
    end

    subgraph AKS ["AKS Cluster Workloads"]
        direction TB
        Front("Frontend Deployment (2 pods)")
        Back("Backend API (2 pods)")
        Worker("Worker (1 pod)")
        DB[("PostgreSQL Pod")]
        
        ALB ===>|Port 80| Front
        Front <-->|ClusterIP: shoe-backend| Back
        Back <-->|ClusterIP: postgres| DB
        Back -.->|Async Queue| Worker
    end

    Users("Users") ===> ALB
    ACR -.->|Pulls Image| AKS
```

---

## Key Security Practices

* **No Hardcoded Secrets:** Password and keys are pulled directly from Jenkins at runtime.
* **RBAC:** We use a Terraform Service Principal that only has exactly the permissions it needs (like `Storage Blob Data Contributor` for saving reports).
* **Managed Identities:** AKS nodes use managed identities to authenticate with Azure Container Registry. No docker login passwords hanging around.
* **Network Security Groups:** Traffic is strictly controlled between subnets.
* **Shift Left:** Code goes through 5 different security tools before it's allowed to run.

## Stack Summary

* **Cloud:** Azure
* **Infrastructure:** Terraform
* **Orchestration:** Azure Kubernetes Service (AKS)
* **Storage:** Azure Container Registry (ACR), Azure Blob Storage, Azure Log Analytics
* **CI/CD:** Jenkins, Git
* **Security Scanners:** SonarQube, OWASP Dependency-Check, Gitleaks, Trivy, Checkov
* **Database:** PostgreSQL

## What's Next?

If I were moving this into a real production environment, I'd probably add:
* **ZAP (DAST):** Run a dynamic application scan against the load balancer URL right after deployment.
* **Azure API Management:** Stick APIM in front of the cluster to handle rate limiting and OAuth.
* **External Secrets:** Move away from Jenkins injecting secrets and use the Azure Key Vault CSI driver so pods can mount secrets straight from the vault.
* **Managed DB:** Move Postgres out of a kubernetes pod and into a proper Azure Database for PostgreSQL.
