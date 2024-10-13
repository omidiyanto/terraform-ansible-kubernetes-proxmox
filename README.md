
# 🌟 Kubernetes (K8s) Cluster Automation on Proxmox VE with Terraform and Ansible🚀
<div align="center">
    <!-- Your badges here -->
    <img src="https://img.shields.io/badge/kubernetes-blue?style=for-the-badge&logo=kubernetes&logoColor=white">
    <img src="https://img.shields.io/badge/terraform-%238511FA.svg?style=for-the-badge&logo=terraform&logoColor=white">
    <img src="https://img.shields.io/badge/ansible-%23000.svg?style=for-the-badge&logo=ansible&logoColor=white">
    <img src="https://img.shields.io/badge/proxmox-%23FF6F00.svg?style=for-the-badge&logo=proxmox&logoColor=white">
    <img src="https://img.shields.io/badge/ubuntu-%23D00000.svg?style=for-the-badge&logo=ubuntu&logoColor=white">
</div>

Welcome to the **Kubernetes Cluster Automation on Proxmox VE with Terraform and Ansible** project! This repository is designed to help you effortlessly set up a robust Kubernetes (K8s) cluster using **Terraform** and **Ansible**. If you're looking to streamline your K8s deployment process on Proxmox Virtual Environment, you’re in the right place!

## 📖 Project Overview
<img src=https://github.com/user-attachments/assets/cbe22844-e705-4e43-ad32-2540c02dcbd7>
In this project, you will find a comprehensive solution for automating the creation of a Kubernetes (K8s) cluster that consists of one master node and two worker nodes. By leveraging Infrastructure as Code (IaC) and configuration management tools, you can set up a scalable environment for deploying your containerized applications with minimal effort.

### 🚀 Key Features

- **Terraform**: Utilize Terraform for provisioning and managing the Proxmox virtual machines, enabling consistent and repeatable deployments.
- **Ansible**: Use Ansible playbooks to automate the installation and configuration of Kubernetes components, ensuring a smooth and efficient setup process.
- **Kubernetes**: Deploy a fully functional K8s cluster, complete with one master and two worker nodes, ready for your containerized applications.

## 🛠️ Technologies Used

- **Terraform**: As Infrastructure as Code tool to provisioning servers.
- **Ansible**: For automating configuration management and installation.
- **Kubernetes**: The leading platform for container orchestration.
- **Proxmox VE**: An open-source server virtualization management platform.

## 📦 Getting Started

### Prerequisites

Before you begin, ensure you have the following set up:

- A running **Proxmox VE** environment.
- **Terraform** and **Ansible** installed on proxmox machine.
- Pre-configured VM Template with cloud-init.
- Proxmox API token ID and secret

### Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/omidiyanto/terraform-ansible-kubernetes-proxmox.git
   cd terraform-ansible-kubernetes-proxmox
	```
2. **Rename example.terraform.tfvars to terraform.tfvars**
	```bash
	mv example.terraform.tfvars terraform.tfvars
	```
3. **Edit the content of terraform.tfvars**
	```bash
	vim terraform.tfvars
	```
4. **Fill the Required Variables**
	```bash
	# API proxmox
	proxmox_api_url  ="https://PROXMOX_SERVER:8006/api2/json/"
	proxmox_api_token_id  =  "PROXMOX_API_TOKEN_ID"
	proxmox_api_token_secret  =  "PROXMOX_API_TOKEN_SECRET"

	# cloud-init configuration
	ci_user  =  "YOUR_CLOUD_INIT_USER"
	ci_password  =  "YOUR_CLOUD_INIT_USER_PASSWORD"
	ci_ssh_public_key  =  "~/.ssh/id_rsa.pub"
	ci_ssh_private_key  =  "~/.ssh/id_rsa"
	```
5. **Initialize Pre-required components and provider**
	```bash
	terraform init
	```
6. **Apply or Start Provisioning the Infrastructure and Automatically Create the K8s Cluster**
	```bash
	terraform apply
	```
	Type '**yes**' when prompted to start provisioning !
	Wait until the processed finished. It should not be long, only around 8-15 minutes.

7. **Validate the Cluster**
		Login to the master-node via SSH
	```bash
	ssh ci-user@k8s-master-IP-Address
	```
	
	Validate all nodes are in '**Ready**' state
	```bash
	kubectl get nodes 
	```
	Validate all pods are in '**Running**' state
	```bash
	kubectl get pods -A
	```
	
8. **FINISH**
<br>
