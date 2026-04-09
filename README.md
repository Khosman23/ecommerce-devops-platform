# E-Commerce DevOps Platform

A production-grade, multi-region e-commerce microservices platform built to demonstrate senior-level DevOps engineering skills across the full stack — from containerized application development to cloud infrastructure, Kubernetes orchestration, GitOps, CI/CD automation, and live observability.

---

## Architecture Overview

```
GitHub Repository
       │
       ▼
GitHub Actions CI/CD Pipeline
  ├── Test Services (Node.js, Python, Go)
  ├── Security Scan (Trivy)
  ├── Build & Push Docker Images → Azure Container Registry
  └── Deploy to AKS (West Europe + East US)
       │
       ▼
Azure Kubernetes Service (Multi-Region)
  ├── api-gateway (Node.js)      — Public entry point, port 3000
  ├── user-service (Python)      — User management, port 3001
  └── product-service (Go)       — Product catalog, port 3002
       │
  Istio Service Mesh             — mTLS, traffic control, observability
  ArgoCD                         — GitOps auto-deployment
  Prometheus + Grafana           — Live metrics and dashboards
```

---

## Tech Stack

| Category | Tool |
|---|---|
| CI/CD | GitHub Actions |
| IaC | Azure Bicep |
| Cloud | Microsoft Azure (AKS, ACR, Key Vault, VNet) |
| Containers | Docker |
| Orchestration | Kubernetes (AKS) |
| Service Mesh | Istio |
| GitOps | ArgoCD |
| Security Scanning | Trivy |
| Monitoring | Prometheus + Grafana (kube-prometheus-stack) |
| Languages | Node.js, Python (FastAPI), Go |

---

## Project Structure

```
ecommerce-devops-platform/
├── .github/
│   └── workflows/
│       └── ci-cd.yaml              # GitHub Actions pipeline
├── services/
│   ├── api-gateway/                # Node.js — routes traffic
│   ├── user-service/               # Python/FastAPI — user management
│   └── product-service/            # Go — product catalog
└── infrastructure/
    ├── bicep/
    │   ├── main.bicep              # Entry point — deploys everything
    │   └── modules/
    │       ├── aks.bicep           # Kubernetes clusters
    │       ├── acr.bicep           # Container registry
    │       ├── keyvault.bicep      # Secrets management
    │       └── network.bicep       # Virtual networks
    ├── kubernetes/
    │   └── base/
    │       ├── api-gateway.yaml
    │       ├── user-service.yaml
    │       ├── product-service.yaml
    │       ├── istio-gateway.yaml
    │       └── argocd-app.yaml
    └── monitoring/
        ├── prometheus-values.yaml
        ├── grafana-values.yaml
        ├── alerting-rules.yaml
        ├── servicemonitor.yaml
        └── install.sh
```

---

## Services

### api-gateway (Node.js)
The single public entry point. All external requests hit port 3000 here first. Routes `/api/users` to the user-service and `/api/products` to the product-service using HTTP proxy middleware. Includes Kubernetes health checks at `/health`.

### user-service (Python/FastAPI)
Handles all user-related operations. Exposes REST endpoints for listing, fetching, creating and deleting users. Built with FastAPI and Pydantic for automatic request validation.

### product-service (Go)
Manages the product catalog. Written in Go using the standard `net/http` library — no frameworks. Compiled into a single binary using a multi-stage Docker build, resulting in a minimal final image.

---

## Infrastructure (Bicep IaC)

All Azure infrastructure is defined as code using Bicep. A single command provisions everything:

```bash
az deployment sub create \
  --name "ecommerce-infrastructure" \
  --location "westeurope" \
  --template-file infrastructure/bicep/main.bicep
```

**What gets provisioned:**
- 2 Resource Groups (West Europe + East US)
- 2 AKS Clusters (one per region)
- 1 Azure Container Registry (shared)
- 1 Azure Key Vault
- 2 Virtual Networks with dedicated subnets

---

## CI/CD Pipeline (GitHub Actions)

The pipeline runs automatically on every push to `main`. Four sequential stages:

```
Test Services → Security Scan → Build & Push → Deploy to AKS
    ~27s            ~1m 36s         ~1m 31s        ~1m 26s
```

**Stage 1 — Test Services:** Installs dependencies and runs build verification for all three services.

**Stage 2 — Security Scan:** Builds Docker images and scans each one with Trivy for HIGH and CRITICAL vulnerabilities before they ever reach the registry.

**Stage 3 — Build & Push:** Authenticates with Azure, builds production Docker images, and pushes them to ACR with both a commit SHA tag and `latest`.

**Stage 4 — Deploy to AKS:** Pulls AKS credentials, updates the running deployments with the new image tags, and verifies each rollout completes successfully.

---

## Kubernetes & Istio

Each service runs with 2 replicas for high availability. Istio sidecar injection is enabled on the `ecommerce` namespace — every pod runs 2 containers (the app + the Istio proxy).

Istio provides:
- Automatic mTLS between all services
- Traffic routing via Gateway and VirtualService
- Full observability of service-to-service communication

---

## GitOps with ArgoCD

ArgoCD watches the `infrastructure/kubernetes/base` folder in this repository. Any change pushed to GitHub is automatically detected and synced to the cluster — no manual `kubectl` commands needed in production.

---

## Monitoring

Prometheus and Grafana are deployed via Helm using the `kube-prometheus-stack` chart. Pre-built dashboards include:

- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace
- Kubernetes / Networking / Cluster
- Node Exporter / Full

Custom alerting rules fire on: service down, CPU > 80%, memory > 80%, error rate > 10%.

---

## Multi-Region Design

Running in both West Europe and East US provides:
- **High availability** — if one region fails, the other keeps serving traffic
- **Lower latency** — European users hit West Europe, American users hit East US
- **Disaster recovery** — full redundancy at the infrastructure level

---

## Getting Started

### Prerequisites
- Azure CLI
- kubectl
- Helm
- Docker
- istioctl

### Deploy Infrastructure
```bash
az login
az deployment sub create \
  --name "ecommerce-infrastructure" \
  --location "westeurope" \
  --template-file infrastructure/bicep/main.bicep
```

### Connect to Cluster
```bash
az aks get-credentials \
  --resource-group ecommerce-prod-we-rg \
  --name ecommerce-prod-we-aks
```

### Deploy Services
```bash
kubectl apply -f infrastructure/kubernetes/base/
```

### Install Monitoring
```bash
cd infrastructure/monitoring
bash install.sh
```

---

## Author

Khalid Hassan Osman