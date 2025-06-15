# Production-Ready Infrastructure and Deployment Guide

This guide outlines the steps to set up a production-ready infrastructure using Terraform and deploy the Wazuh stack using Ansible.

## Prerequisites

1. **Terraform**: Install Terraform from [terraform.io](https://www.terraform.io/).
2. **Ansible**: Install Ansible from [ansible.com](https://www.ansible.com/).
3. **AWS CLI**: Configure AWS credentials using `aws configure`.
4. **SSH Key**: Ensure your AWS key pair is available locally.

## Steps

### 1. Deploy Infrastructure with Terraform

1. Navigate to the Terraform directory:
   ```bash
   cd terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```
   - Review the plan and type `yes` to confirm.

4. Note the output values (public IPs of Wazuh components).

### 2. Configure and Deploy with Ansible

1. Navigate to the Ansible directory:
   ```bash
   cd ../ansible
   ```

2. Update the inventory file with the IPs from Terraform outputs:
   ```ini
   [wi1]
   <wazuh_master_ip>

   [wi2]
   <wazuh_worker_ip>

   [wi_cluster]
   <wazuh_indexer_ips>

   [dashboard]
   <wazuh_dashboard_ip>
   ```

3. Run the Ansible playbook:
   ```bash
   ansible-playbook wazuh-production-ready.yml
   ```

## Notes

- Replace `<wazuh_master_ip>`, `<wazuh_worker_ip>`, `<wazuh_indexer_ips>`, and `<wazuh_dashboard_ip>` with the actual IPs from Terraform outputs.
- Ensure SSH access to the instances is configured correctly.

## Troubleshooting

- Check Terraform logs for infrastructure issues.
- Use `ansible-playbook -vvv` for verbose output during playbook execution.

## Terraform Configuration Details

### Provider Configuration
- **AWS Provider**: Configures the AWS region using the `var.aws_region` variable. Ensure you set this variable in your Terraform variables file or environment.

### Security Group
- **Resource**: `aws_security_group.wazuh_sg`
  - Allows SSH access (port 22).
  - Opens ports 1514-1516 for Wazuh server communication.
  - Opens port 9200 for Elasticsearch.
  - Opens port 5601 for Kibana.
  - Allows all outbound traffic.

### Instances

#### Wazuh Master Node
- **Resource**: `aws_instance.wazuh_master`
  - AMI: `ami-0c55b159cbfafe1f0` (Amazon Linux 2).
  - Instance Type: `c5.xlarge`.
  - Key Pair: Replace `your-key-pair` with your actual key pair.
  - Security Group: `wazuh_sg`.
  - Root Volume: 100 GB, `gp3` type.
  - User Data: Installs Wazuh Manager and configures it as a master node.

#### Wazuh Worker Node
- **Resource**: `aws_instance.wazuh_worker`
  - Similar configuration to the master node but installs Wazuh Manager as a worker node.

#### Wazuh Indexer Nodes
- **Resource**: `aws_instance.wazuh_indexer`
  - Count: 3 instances.
  - AMI: `ami-0c55b159cbfafe1f0`.
  - Instance Type: `m5.xlarge`.
  - Key Pair: Replace `your-key-pair` with your actual key pair.
  - Security Group: `wazuh_sg`.
  - Root Volume: 200 GB, `gp3` type.
  - User Data: Installs Wazuh Indexer.

#### Wazuh Dashboard Node
- **Resource**: `aws_instance.wazuh_dashboard`
  - AMI: `ami-0c55b159cbfafe1f0`.
  - Instance Type: `t3.medium`.
  - Key Pair: Replace `your-key-pair` with your actual key pair.
  - Security Group: `wazuh_sg`.
  - Root Volume: 50 GB, `gp3` type.
  - User Data: Installs Wazuh Dashboard.

### Outputs
- **Wazuh Master IP**: `wazuh_master_ip`.
- **Wazuh Worker IP**: `wazuh_worker_ip`.
- **Wazuh Indexer IPs**: `wazuh_indexer_ips`.
- **Wazuh Dashboard IP**: `wazuh_dashboard_ip`.

These outputs map to the Ansible inventory file for deploying the Wazuh stack.

### Updated Documentation for Terraform and Ansible Integration

#### Security Group
- **Resource**: `aws_security_group.wazuh_sg`
  - Ensures secure communication between Wazuh components.
  - Ports opened:
    - **22**: SSH access for configuration and management.
    - **1514-1516**: Wazuh server communication.
    - **9200**: Elasticsearch communication.
    - **5601**: Kibana dashboard access.

#### Instances

1. **Wazuh Master Node**
   - **Terraform Resource**: `aws_instance.wazuh_master`
   - **Purpose**: Hosts the Wazuh Manager configured as the master node.
   - **Ansible Mapping**: Maps to the `wi1` group in the inventory.

2. **Wazuh Worker Node**
   - **Terraform Resource**: `aws_instance.wazuh_worker`
   - **Purpose**: Hosts the Wazuh Manager configured as a worker node.
   - **Ansible Mapping**: Maps to the `wi2` group in the inventory.

3. **Wazuh Indexer Nodes**
   - **Terraform Resource**: `aws_instance.wazuh_indexer`
   - **Purpose**: Hosts the Wazuh Indexer cluster.
   - **Ansible Mapping**: Maps to the `wi_cluster` group in the inventory.

4. **Wazuh Dashboard Node**
   - **Terraform Resource**: `aws_instance.wazuh_dashboard`
   - **Purpose**: Hosts the Wazuh Dashboard for monitoring and management.
   - **Ansible Mapping**: Maps to the `dashboard` group in the inventory.

#### Outputs
- **Wazuh Master IP**: Used to configure the master node in the Ansible playbook.
- **Wazuh Worker IP**: Used to configure the worker node in the Ansible playbook.
- **Wazuh Indexer IPs**: Used to configure the indexer cluster in the Ansible playbook.
- **Wazuh Dashboard IP**: Used to configure the dashboard node in the Ansible playbook.

### How Terraform Resources Support the Playbook
- The security group ensures all necessary ports are open for communication between components.
- Each instance is pre-configured with user data scripts to install the required Wazuh components.
- The outputs provide the IPs needed to populate the Ansible inventory file, ensuring seamless deployment.
