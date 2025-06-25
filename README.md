# Super-Mario-EKS-deployment
# Super Mario on AWS EKS with Terraform

This project deploys a **Super Mario game container** onto an **AWS EKS (Kubernetes)** cluster provisioned using **Terraform**. It includes:
- Infrastructure-as-Code (VPC, EKS Cluster, Node Groups, IAM Roles, S3 Backend)
- Kubernetes manifests (Deployment & Service) to expose the game
- Load Balancer to access the game on the public internet

---

## Architecture Overview
1. **AWS EKS** cluster deployed with Terraform.
2. Application deployed as a Kubernetes **Deployment**.
3. Application exposed via a Kubernetes **Service (LoadBalancer)**.
4. Traffic routed through an AWS Load Balancer.

---

##  Prerequisites
- AWS CLI installed & configured
- kubectl installed
- Terraform installed
- Docker image (`my-dockerhub-username/supermario:latest`) available publicly
- AWS credentials with permissions for creating EKS resources

---

