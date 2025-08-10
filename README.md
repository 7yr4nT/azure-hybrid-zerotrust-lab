# Automated Zero Trust Hybrid Cloud Network on Azure

![Azure](https://img.shields.io/badge/Azure-blue?style=for-the-badge&logo=microsoftazure)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform)
![Zero Trust](https://img.shields.io/badge/Security-Zero%20Trust-brightgreen?style=for-the-badge)
![IaC](https://img.shields.io/badge/Automation-IaC-orange?style=for-the-badge)

<img width="1806" height="871" alt="Diagram" src="https://github.com/user-attachments/assets/f7fd1a75-979f-4b17-8859-c1328654272d" />


This project demonstrates the creation of a secure, automated hybrid cloud environment. It connects a simulated on-premises network running on a local hypervisor (VirtualBox/VMware) to a Microsoft Azure Virtual Network (VNet). The entire Azure infrastructure is deployed automatically using **Terraform**, and security is enforced using a **Zero Trust Network Access (ZTNA)** model.

This repository contains the Infrastructure as Code for the **Azure side** of the project.

***

## 🚀 Core Concepts Demonstrated

| Concept                      | Description                                                                                                                                              |
| :--------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Infrastructure as Code (IaC)** | The entire cloud infrastructure is codified using Terraform, ensuring a fully automated, repeatable, and version-controlled deployment process.        |
| **Hybrid Cloud Networking** | A stable Site-to-Site IPsec VPN is established between an on-premises pfSense firewall and an Azure VPN Gateway, creating a secure network underlay.       |
| **Hybrid Identity Management** | On-premises Active Directory users are synchronized to Microsoft Entra ID, creating a unified identity plane for seamless and secure access.             |
| **Zero Trust Security (ZTNA)** | A secure overlay network is implemented where access is granted based on **identity**, not network location, enforcing the principle of least privilege. |
| **Cross-Platform Proficiency** | The architecture was successfully migrated from AWS to Microsoft Azure, showcasing a deep understanding of core cloud principles independent of the provider. |

***

## 🛠️ Technology Stack

| Domain             | Technology                        | Purpose & Rationale                                                                        |
| :----------------- | :-------------------------------- | :----------------------------------------------------------------------------------------- |
| **Cloud Provider** | Microsoft Azure                   | Chosen to demonstrate cross-platform proficiency in a leading enterprise cloud ecosystem.      |
| **IaC / Automation** | Terraform, Docker                 | **Terraform:** Automates provisioning of all Azure resources. **Docker:** Containerizes the web application for portability. |
| **Identity** | Windows Server AD DS, Microsoft Entra ID | **AD DS:** The authoritative source for on-prem identity. **Entra ID:** The cloud identity control plane. |
| **Networking** | pfSense, Azure VNet & VPN Gateway | Provides foundational routing, firewalling, and secure site-to-site connectivity.          |
| **Security** | Tailscale, Azure NSGs             | **Tailscale:** Implements the Zero Trust model. **NSGs:** Provide essential infrastructure-level traffic filtering. |
| **Virtualization** | Oracle VirtualBox / VMware        | A cost-effective and flexible platform for simulating the on-premises environment.         |

***

## ⚙️ Replication Guide: Step-by-Step

Replicating this project requires two main phases: **(1)** Manually building the simulated on-premises lab and **(2)** Automatically deploying the Azure infrastructure and connecting the two.

### **Phase 0: Prerequisites & Tools**

| Tool               | Download Link                                                                                                 | Purpose                                    |
| :----------------- | :------------------------------------------------------------------------------------------------------------ | :----------------------------------------- |
| **Hypervisor** | [VMware Workstation Player](https://www.vmware.com/products/workstation-player/workstation-player-evaluation.html) / [VirtualBox](https://www.virtualbox.org/wiki/Downloads) | To host the on-prem virtual machines.      |
| **Terraform** | [Download Terraform](https://developer.hashicorp.com/terraform/downloads)                                     | The IaC tool to build the Azure environment. |
| **Azure CLI** | [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)                               | To authenticate with your Azure account.     |
| **pfSense** | [Download pfSense](https://www.pfsense.org/download/)                                                         | The firewall/router for the on-prem network. |
| **Tailscale** | [Download Tailscale](https://tailscale.com/download)                                                          | The ZTNA client for secure access.         |

> You will also need ISO files for Windows Server and Windows 10/11, which can be acquired from the Microsoft Evaluation Center.

### **Phase 1: On-Premises Environment Setup (Manual)**

This phase simulates a corporate office network using a local hypervisor.

#### **On-Premises VM Configuration**

| VM Name        | Operating System          | vCPUs | RAM  | Network Adapters                | IP Address (Static) | Role                                   |
| :------------- | :------------------------ | :---- | :--- | :------------------------------ | :------------------ | :------------------------------------- |
| `pfSense-FW`   | pfSense                   | 1     | 1 GB | 2 (WAN: Bridged, LAN: Internal) | `192.168.50.1`      | Firewall, Router, DHCP Server          |
| `WinServer-DC` | Windows Server 2022       | 2     | 2 GB | 1 (LAN: Internal)               | `192.168.50.10`     | AD Domain Controller for `mycorp.local` |
| `Win10-Client` | Windows 10/11 Ent.        | 2     | 2 GB | 1 (LAN: Internal)               | DHCP                | Domain-joined corporate workstation    |

### **Phase 2: Azure Deployment & Connectivity**

This phase deploys the cloud components and links them to your on-prem lab.

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/YourUsername/azure-hybrid-zerotrust-lab.git](https://github.com/YourUsername/azure-hybrid-zerotrust-lab.git)
    cd azure-hybrid-zerotrust-lab/terraform
    ```

2.  **Deploy Azure Infrastructure via Terraform**
    * Authenticate with Azure: `az login`
    * Initialize Terraform: `terraform init`
    * Review the deployment plan: `terraform plan`
    * Apply the configuration to deploy the resources:
        ```terraform
        terraform apply
        ```
    > This provisions the VNet (`10.0.0.0/16`), subnets, NSGs, and an Ubuntu VM running a Dockerized Nginx server.

3.  **Configure Site-to-Site VPN**
    * Use the `public_ip_address` output from Terraform for the Azure VPN Gateway.
    * Configure the IPsec tunnel on your on-premises pfSense firewall to establish the connection with Azure.

4.  **Synchronize Identities**
    * Install **Microsoft Entra Connect** on your on-premises Windows Server Domain Controller.
    * Configure it to synchronize user accounts from `mycorp.local` to your Microsoft Entra ID tenant.

5.  **Implement Zero Trust Network (ZTNA)**
    * Create a **Tailscale** account and link your Entra ID tenant as the identity provider.
    * Install the Tailscale client on your on-prem Windows client VM and the Azure Ubuntu VM.
    * Authenticate on both machines to join them to the secure overlay network, allowing access via their stable Tailscale IPs.

***

## 🌟 Future Enhancements

* **CI/CD Automation**: Implement a GitHub Actions pipeline to automatically run `terraform plan` and `apply` on pull requests and merges.
* **Secrets Management**: Integrate Azure Key Vault to manage sensitive data like passwords and API keys, removing them from plain text files.
* **Monitoring and Logging**: Deploy Azure Monitor to track resource health and stream logs to a Log Analytics Workspace for analysis and auditing.
* **Advanced ZTNA Policies**: Use Tailscale ACLs to define granular, tag-based access policies that enforce the principle of least privilege at the application layer.

