# E-Commerce DevOps Platform

A production-grade, multi-region e-commerce platform built to demonstrate senior-level DevOps engineering across the full stack.

**Live pipeline:** GitHub Actions → Docker → Azure Container Registry → AKS (West Europe + East US)

---

## Tech Stack

| Category | Tool |
|---|---|
| CI/CD | GitHub Actions |
| IaC | Azure Bicep |
| Cloud | Azure (AKS, ACR, Key Vault, VNet) |
| Containers | Docker |
| Orchestration | Kubernetes |
| Service Mesh | Istio |
| GitOps | ArgoCD |
| Security | Trivy |
| Monitoring | Prometheus + Grafana |
| Languages | Node.js, Python (FastAPI), Go |

---

## CI/CD Pipeline — All 4 Stages Green

![GitHub Actions Pipeline](screenshots/github-actions-pipeline.png)

Automated pipeline triggered on every push to main:
- **Test Services** — build verification for all three microservices
- **Security Scan** — Trivy vulnerability scanning on all Docker images
- **Build & Push** — images pushed to Azure Container Registry with commit SHA tag
- **Deploy to AKS** — rolling update to Kubernetes cluster with rollout verification

---

## GitOps with ArgoCD

![ArgoCD App Synced](screenshots/argocd-app-synced.png)

![ArgoCD Visual Map](screenshots/argocd-visual-map.png)

ArgoCD watches the GitHub repository and automatically syncs any changes to the AKS cluster. The visual map shows all Deployments, ReplicaSets, Pods, Istio Gateway and VirtualService running in the ecommerce namespace.

---

## Live Monitoring — Prometheus + Grafana

![Grafana Cluster Metrics](screenshots/grafana-cluster-metrics.png)

![Grafana Networking](screenshots/grafana-networking.png)

Real-time metrics from the live AKS cluster showing CPU utilisation, memory usage per namespace, and network traffic across ecommerce, istio-system, monitoring and kube-system namespaces.

---

## Architecture