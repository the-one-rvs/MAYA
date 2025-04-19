# MAYA 🚀

MAYA is a powerful CLI-driven DevOps automation tool that simplifies the deployment of containerized applications across multiple environments — from local Kubernetes clusters to cloud-native ECS and EKS setups. Designed with scalability, monitoring, and security in mind, MAYA enables developers to deploy applications in a few commands using GitHub Actions, Docker, Helm, and Terraform.

---

## ✨ Features

- 🔘 One-click deployment for:
  - **Amazon ECS**
  - **Amazon EKS**
  - **Kubernetes via kind**
- 🐳 Auto-generated Dockerfiles for backend/frontend services
- ⚙️ CI/CD pipeline with GitHub Actions
- 🎯 GitOps integration with Argo CD
- 📈 Monitoring with Prometheus, Grafana, and K9s
- 🔐 Container security scanning with Trivy
---

## 🛠 Tech Stack

| Tool         | Purpose                          |
|--------------|----------------------------------|
| **Bash**     | CLI scripts for infra automation |
| **Docker**   | Containerization                 |
| **GitHub Actions** | CI/CD pipelines             |
| **Kubernetes** | Container orchestration         |
| **Helm**     | Kubernetes package management    |
| **Terraform**| Infrastructure as Code (IaC)     |
| **Prometheus/Grafana** | Monitoring and dashboards |
| **Trivy**    | Security scanning                |
| **Velero**   | Backup and recovery              |

---

## 📂 Project Structure

```bash
MAYA/
├── .github/workflows/        # GitHub Actions CI/CD
├── choose_infra.sh           # Select ECS, EKS, or Kind
├── ecs.sh                    # Deploy to ECS
├── eks.sh                    # Deploy to EKS
├── kind.sh                   # Deploy to local kind
├── Maya-Kind/                # Helm Charts and manifests
├── Dockerfiles/              # Backend & frontend Dockerfiles
├── ci-pipeline/              # CI/CD helpers
├── observability/            # Prometheus/Grafana configs
└── README.md                 # You are here :)

```
---

## 📥 Installation

You can clone a specific release tag or download the source, then run the `install.sh` script to set up everything.

### 🚀 Steps

#### 1. Clone a Specific Tag

```bash
git clone --branch <tag-name> https://github.com/the-one-rvs/MAYA.git
cd MAYA
chmod +x install.sh
./install.sh
```


