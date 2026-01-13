# Infrastructure as Code (IaC) AWS Private VPC Setup
This repository contains Terraform code to create a private Virtual Private Cloud (VPC) in AWS. The setup includes subnets, route tables, security groups, and other necessary components to establish a secure and isolated network environment.

Below is the Terraform visualization of the infrastructure that's created:

![terraform-visualization](docs/images/terraform-visualization.png)

**Table of Contents**

<!-- toc -->
+ [**1.0 `deploy.sh` script arguments**](#10-deploysh-script-arguments)
    - [**1.1 `subnet_prefix` argument:**](#11-subnet_prefix-argument)
+ [**2.0 Resources**](#20-resources)
<!-- tocstop -->

---

## **1.0 `deploy.sh` script arguments**

### **1.1 `subnet_prefix` argument:**
| **VPC Prefix** | `subnet_prefix` | **newbits** | Resulting Subnets | IPs per Subnet |
|------------|----------------|---------|-------------------|----------------|
| `/16` | `/20` | `4` | 16 subnets | 4,096 |
| `/16` | `/24` | `8` | 256 subnets | 256 |
| `/16` | `/28` | `12` | 4,096 subnets | 16 |
| `/20` | `/24` | `4` | 16 subnets | 256 |
| `/20` | `/28` | `8` | 256 subnets | 16 |
| `/24` | `/28` | `4` | 16 subnets | 16 |

**What you need to know:**
- The **newbits** determines how many additional bits to add to the network prefix for subnettings.
- The **VPC Prefix** is the number after the slash in your VPC's CIDR block.  It indicates **how many bits define the network portion** of the IP address range.
- The `subnet_prefix` is the target prefix length you want for your subnetsafter subdividing your VPC CIDR block.

## **2.0 Resources**
- [CIDR to IPv4 Conversion](https://www.ipaddressguide.com/cidr)