# 🚀 AWS EKS CI/CD Pipeline Project

This project demonstrates a **fully automated CI/CD pipeline** to deploy a simple **NGINX web application** on **AWS EKS** using **Terraform**, **Docker**, **Kubernetes**, and **Jenkins**.

The pipeline provisions infrastructure, builds and pushes Docker images, and deploys the application on a Kubernetes cluster, all in a repeatable and automated manner.

---

## 🌐 Project Architecture

GitHub Repo
│
│
▼
Jenkins Pipeline
├── Terraform Init & Plan
├── Approval
├── Terraform Apply
├── Docker Build & Push
└── Kubernetes Deployment
│
▼
AWS EKS Cluster
│
▼
hello-world NGINX Deployment
│
▼
LoadBalancer Service (External Access)


- **Terraform:** Provision AWS resources (VPC, subnets, IAM roles, EKS cluster, node groups)  
- **Docker:** Containerize the NGINX web app  
- **Kubernetes:** Deploy containers with `Deployment` and `Service` manifests  
- **Jenkins:** Automate CI/CD workflow with approval step  

---

## ⚙️ Technologies Used

| Layer                   | Technology                        |
|-------------------------|---------------------------------  |    
| Infrastructure          | Terraform, AWS |                  |
| CI/CD                   | Jenkins                           |
| Containerization        | Docker                            |
| Orchestration           | Kubernetes (Deployment + Service) |
| Application             | NGINX (Static HTML)               |

---

## 📂 Project Structure

├── Dockerfile
├── index.html
├── Jenkinsfile
├── k8s
│ └── deployment.yaml
├── terraform
│ ├── main.tf
│ ├── provider.tf
│ ├── variables.tf
│ ├── terraform.tfvars
│ └── vpc.tf


---

## 🏗️ Terraform Infrastructure

- **VPC & Networking:**  
  - VPC with CIDR `10.0.0.0/16`  
  - Two public subnets in separate AZs for HA  
  - Internet Gateway and Route Tables for external access  
  - Security Group allowing SSH (22) & HTTP (80)  

- **IAM Roles:**  
  - `eksclusterrole` → EKS cluster  
  - `node-group-role` → worker nodes  

- **EKS Cluster:**  
  - Kubernetes version `1.33`  
  - Managed node group (t3.micro)  
  - Labels for easy identification  

### Terraform Variables Example Dockerfile

```hcl
clustername = "my-eks-cluster"
env         = "dev"
clustersg   = "eks-cluster-sg"
vpcname     = "my-vpc"
pubsub01    = "subnet-pub1"
pubsub02    = "subnet-pub2"
block1      = "10.0.0.0/16"
block2      = "10.0.1.0/24"
block3      = "10.0.2.0/24"
block4      = "10.0.3.0/24"
block5      = "10.0.4.0/24"
block6      = "10.0.5.0/24"
```
---

## **🐳 Dockerfile**

Base image: nginx:1.25-alpine

Copies index.html into container

Exposes port 80

FROM nginx:1.25-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80


## ☸️ Kubernetes Deployment (k8s/deployment.yaml)

Deployment:

2 replicas of hello-world container

readinessProbe and livenessProbe for health checks

Service:

Type: LoadBalancer

Maps external port 80 to container port 80

apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world-container
        image: <your-dockerhub-username>/hello-world:v1
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  type: LoadBalancer
  selector:
    app: hello-world
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80




## 🔧 Jenkins Pipeline Overview

Checkout: Pulls source code from GitHub

Terraform Init & Plan: Initializes Terraform and creates execution plan

Approval: Waits up to 30 minutes for manual approval

Terraform Apply: Applies infrastructure changes

Docker Build & Push: Builds the NGINX Docker image and pushes to Docker Hub

Update kubeconfig: Configures access to EKS cluster

Deploy to Kubernetes: Applies Deployment and Service YAMLs, updates image, ensures rollout success

Features:

Manual approval before Terraform apply

Automatic image versioning using BUILD_NUMBER

Rollout verification


## 🚀 Deployment Steps

Configure AWS credentials:

aws configure


Trigger Jenkins pipeline

Access deployed app via LoadBalancer URL:

kubectl get svc hello-world-service

## 📌 Notes

Update index.html for custom web content

Update deployment.yaml for new Docker images

Ensure Jenkins agent has Docker and AWS CLI installed

Security groups can be adjusted for production requirements

