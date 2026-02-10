# InfraWeave: Automated AWS Cloud Orchestration
---------------------------------------------

**InfraWeave** is an expert-level Infrastructure-as-Code (IaC) and Configuration Management project designed to provision a high-availability AWS environment and automate the deployment of containerized web applications. By integrating **Terraform** for resource provisioning and **Ansible** for orchestration, it ensures a "zero-touch" deployment pipeline from bare infrastructure to live applications.

* * * * *

## 🏗️ Architecture Overview
-------------------------

The project architecturally splits the environment into a Control Plane and a Managed Worker Cluster:

-   **Custom VPC**: A dedicated network with public subnets, internet gateways, and optimized routing tables.

-   **Ansible Control Plane**: A central management node pre-configured with Ansible, automated host discovery, and workspace migration.

-   **Managed Worker Cluster**: A scalable set of EC2 instances (node1, node2, node3) optimized for containerized workloads.

-   **Security Architecture**: Dynamic security groups utilizing HCL loops to manage ingress traffic for SSH (22), HTTP (80, 81), and HTTPS (443).

* * * * *

## 🚀 Key Features
---------------

-   **Infrastructure as Code (IaC)**: Pure HCL-based resource management with Terraform for predictable deployments.

-   **Automated Bootstrapping**: Shell-based initialization (`ansible.sh`, `nodes.sh`) for user management (`itadmin`), SSH hardening, and software installation.

-   **Containerized Micro-Deployment**: An Ansible playbook that dynamically maps specific Docker images to different nodes:

    -   **Node 1**: Painter Repository (`hackwithabhi/painterrepo`)

    -   **Node 2**: Tourist Site (`hackwithabhi/tourist2025`)

    -   **Node 3**: Jewellery Platform (`hackwithabhi/jewellery:v1`)

-   **Intelligent Orchestration**: Automated `/etc/hosts` mapping during the Terraform apply phase for internal name resolution.

-   **Expert Handshake Logic**: Robust `remote-exec` provisioners with wait loops to handle race conditions during initial setup.

* * * * *

## 🛠️ Technology Stack
--------------------

| **Component** | **Tool** |
| --- | --- |
| **Cloud Provider** | AWS (EC2, VPC, IGW, Route Tables) |
| **Infrastructure** | Terraform |
| **Configuration** | Ansible |
| **Containerization** | Docker |
| **Operating System** | Amazon Linux 2 / 2023 |

* * * * *

## 📂 Project Structure
--------------------

-   `main.tf`: Core infrastructure logic (VPC, Security Groups, EC2 Cluster).

-   `vars.tf`: Variable definitions for region, AMI, and credentials.

-   `outputs.tf`: Public and Private IP mapping for easy access.

-   `ansible.sh`: Control node bootstrap (Ansible install, user creation).

-   `nodes.sh`: Worker node bootstrap (Docker install).

-   `playbook.yml`: Ansible logic for multi-container deployment.

* * * * *

## 🚦 Quick Start
--------------

### 1\. Initialize Infrastructure

Bash

```
terraform init
terraform apply --auto-approve

```

### 2\. Verify Output

- Terraform will output the **Ansible Server Public IP**. Note this for the next step.

### 3\. Orchestrate

- SSH into the control node using the `itadmin` user and the password configured in your variables:

Bash

```
ssh itadmin@<ansible_public_ip>
cd /home/itadmin/punepro/
ansible-playbook playbook.yml

```

* * * * *

## 🛡️ Security Note
-----------------

- For production environments, ensure you restrict the Security Group CIDR blocks in `main.tf` from `0.0.0.0/0` to your specific office or home IP address.
-----------------

## 📊 Outputs

- Upon successful execution, InfraWeave provides:

- Ansible Control Node: Public and Private IPs.

- Node Cluster: Dynamic list of all worker node IPs.
