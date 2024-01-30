# Azure-vms-ansible-lab-w-terraform

**Objective:**
The Terraform code aims to create resources in Azure, including a Virtual Network, Subnet, Virtual Machines (Linux and Windows), Network Interfaces, and a Network Security Group.

**Created Resources:**
1. **Resource Group:**
   - A resource group named `${var.resource_group_name}` is created.

2. **Virtual Network:**
   - A Virtual Network named `${var.network_name}` is created with the address range `10.10.0.0/16`.

3. **Subnet:**
   - A Subnet named `${var.subnet_name}` is created within the Virtual Network with the address range `10.10.2.0/24`.

4. **Network Security Group:**
   - A Network Security Group named "SecurityGroupAnsibleTest" is created with a rule allowing TCP traffic on any port.

5. **Network Interfaces (NIC):**
   - Network Interfaces are created for each virtual machine, associated with the Subnet and Network Security Group.

6. **Virtual Machines:**
   - Linux and Windows Virtual Machines are created. Linux machines are based on Debian, CentOS, or Ubuntu images, while the Windows machine is based on Windows Server 2016.
   - Virtual machines are associated with the corresponding Network Interfaces.
   - Linux machines use SSH keys for authentication, while the Windows machine uses a password.

**Notes:**
- The code uses `for_each` loops to dynamically create resources based on a list of specified virtual machines in the variables.
- Virtual machines are associated with the Network Security Group to control network traffic.

**Requirements:**
- Terraform v3.0.0 or higher.
- An Azure subscription with the specified ID.

**Usage Instructions:**
1. Configure your Azure credentials.
2. Run `terraform init` to initialize the environment.
3. Run `terraform apply` to create the resources.
4. Review the outputs for information about the created resources.

This code serves as a starting point for provisioning resources in Azure. Make sure to customize the variables as needed to meet the specific requirements of your project.