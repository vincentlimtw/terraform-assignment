# Terraform Assignment

This project demonstrates a Terraform infrastructure that exposes `k8s.gcr.io/e2e-test-images/echoserver:2.5` to the internet using a dual-VPC (connected via Transit Gateway) architecture on AWS.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Data Flow](#data-flow)
- [Security Flaws](#security-flaws)
- [Design Trade-offs](#design-trade-offs)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Modules](#modules)
- [Variables](#variables)
- [Usage](#usage)
- [Outputs](#outputs)
- [Cleanup](#cleanup)
- [Scheduled Job Recommendation](#scheduled-job-recommendation)
- [AI Usage](#ai-usage)

---

## Architecture Overview

Two VPCs are connected via a Transit Gateway, separating public-facing infrastructure from private workloads.

```
Internet
    │
    ▼
┌─────────────────────────────────────┐
│         Internet VPC                │
│  ┌──────────────┐  ┌─────────────┐  │
│  │ Internet ALB │  │ NAT Gateway │  │
│  │  (public)    │  │ (gateway-a) │  │
│  └──────┬───────┘  └─────────────┘  │
│         │  TGW Attachment           │
└─────────┼─────────────────────────--┘
          │ Transit Gateway
┌─────────┼─────────────────────────────┐
│         │  TGW Attachment             │
│         │  Workload VPC               │
│  ┌──────▼──────┐     ┌─────────────┐  │
│  │  NLB        │────▶│  ALB        │  │
│  │ (internal)  │     │ (internal)  │  │
│  └─────────────┘     └──────┬──────┘  │
│                             │         │
│                      ┌──────▼──────┐  │
│                      │ ECS Fargate │  │
│                      │ echoserver  │  │
│                      └──────┬──────┘  │
│                             │         │
│                     ┌───────▼───────┐ │
│                     │ Aurora MySQL  │ │
│                     │ Serverless v2 │ │
│                     └───────────────┘ │
└───────────────────────────────────────┘
```

- **Internet VPC** — public-facing layer hosting the internet ALB and NAT gateway
- **Workload VPC** — private layer hosting the internal NLB and ALB, ECS tasks, and Aurora database
- **Transit Gateway** — connects both VPCs and manages cross-VPC routing

---

## Data Flow

1. Request hits the **Internet ALB** (public, Internet VPC) on port 80
2. Internet ALB forwards to the **Workload NLB's ENI private IPs** as IP targets. Traffic crosses VPCs via the Transit Gateway
3. **NLB** (internal, Workload VPC) forwards to the **Workload ALB** registered as its target
4. **Workload ALB** (internal) forwards to ECS Fargate tasks on port 8080
5. **ECS Fargate** runs the echoserver container and returns the response

---

## Security Flaws

**1. No AWS Network Firewall**

The firewall subnet exists in the Internet VPC but has no firewall resource deployed, allowing network traffic to pass through uninspected. An attacker can send malicious packets, scan the network, or attempt to access internal resources without any network-level filtering.

**2. No WAF on Internet ALB**

There is no Web Application Firewall attached to the Internet ALB, meaning application-layer traffic is not inspected or filtered. An attacker can send malicious requests such as SQL injection or XSS directly to the ALB without any protection.

**3. Shared Transit Gateway between public and private traffic**

Both the Internet VPC and Workload VPC share the same Transit Gateway. If the route tables are misconfigured, traffic from the Internet VPC could reach internal workload resources directly, bypassing the intended network separation.

---

## Design Trade-offs

**1. Single NAT gateway — cost vs. availability**

Only one NAT gateway is provisioned in `gateway-a`. If AZ-a goes down, all outbound internet traffic from the Workload VPC is lost. The trade-off is cost savings over high availability, which is acceptable for a dev environment but not for production.

**2. NLB → ALB chaining — simplicity vs. latency**

The NLB→ALB pattern is used to bridge traffic across VPCs via the TGW. This adds an extra hop and requires a 180-second wait for the NLB to provision network interfaces, which can cause apply failures if AWS is slow. The trade-off is architectural separation at the cost of added complexity and latency.

**3. Transit Gateway — scalability vs. cost**

Transit Gateway (TGW) incurs per-attachment and per-GB charges. For just two VPCs, VPC Peering would be simpler and cheaper. The trade-off is paying for TGW’s ability to scale to many VPCs, which may not be needed yet.

---

## Prerequisites

- Terraform ≥ 1.0
- AWS CLI configured with sufficient IAM permissions
- Target region: `ap-southeast-1`

---

## Project Structure

```
.
├── dev.tfvars        # Dev environment values
├── locals.tf         # Resource name prefix
├── main.tf           # Root module — wires all modules together
├── outputs.tf        # Root outputs
├── provider.tf       # AWS and time provider declarations
├── variables.tf      # Input variable definitions and defaults
└── modules/
    ├── alb/          # Internet ALB, Workload NLB, and Workload ALB
    ├── aurora/       # Aurora MySQL Serverless v2 cluster
    ├── ecs/          # ECS cluster, task definition, and Fargate service
    ├── nat/          # Elastic IP and NAT Gateway
    ├── routing/      # Route Tables and Subnet Associations
    ├── security/     # Security Groups for all components
    ├── tgw/          # Transit Gateway, Attachments, and Route Tables
    └── vpc/          # VPCs, Subnets, and Internet Gateway

```

---

## Modules

| Module | Description |
|--------|-------------|
| `alb` | Internet-facing ALB, internal NLB, internal ALB, and cross-VPC target wiring |
| `aurora` | Aurora MySQL Serverless v2 cluster and writer instance |
| `ecs` | ECS cluster, IAM execution role, CloudWatch log group, task definition, and Fargate service |
| `nat` | Elastic IP and NAT Gateway placed in the gateway subnet |
| `routing` | Route tables for all subnet tiers and their associations |
| `security` | Security groups for the Internet ALB, Workload ALB, ECS, and Aurora |
| `tgw` | Transit Gateway with custom route tables and attachments to both VPCs |
| `vpc` | Creates the Internet and Workload VPCs, all subnets, and the Internet Gateway |

---

## Variables

| Variable | Description |
|----------|-------------|
| `aws_region` | AWS region to deploy into |
| `prefix` | Prefix for all resource names |
| `environment` | Environment label |
| `internet_vpc_cidr` | Internet VPC CIDR |
| `workload_vpc_cidr` | Workload VPC CIDR |
| `internet_subnets` | Map of Internet VPC subnets (cidr, az) |
| `workload_subnets` | Map of Workload VPC subnets (cidr, az) |
| `container_image` | Container image to run |
| `task_cpu` | ECS task CPU units |
| `task_memory` | ECS task memory in MB |
| `desired_count` | Number of ECS tasks |
| `log_retention_days` | CloudWatch log retention in days |
| `container_port` | Port the container listens on |
| `engine_version` | Aurora MySQL engine version |
| `database_name` | Initial database name |
| `min_capacity` | Aurora minimum ACU capacity |
| `max_capacity` | Aurora maximum ACU capacity |
| `db_port` | Database port |
| `workload_nlb_tg_port` | Workload NLB target group port |
| `workload_nlb_lis_port` | Workload NLB listener port |
| `workload_alb_tg_port` | Workload ALB target group port |
| `workload_alb_lis_port` | Workload ALB listener port |
| `internet_alb_tg_port` | Internet ALB target group port |
| `internet_alb_lis_port` | Internet ALB listener port |

---

## Usage

**1. Clone the repository and navigate to the directory**
```bash
git clone https://github.com/vincentlimtw/terraform-assignment
cd terraform-assignment
```

**2. Initialise Terraform**
```bash
terraform init
```

**3. Review the plan**
```bash
terraform plan -var-file=dev.tfvars
```

**4. Apply**
```bash
terraform apply -var-file=dev.tfvars
```

> **Note:** The first apply takes approximately 5–8 minutes. The ALB module waits 180 seconds for the NLB's ENIs to fully provision before looking up their IPs and registering them as targets.

---

## Outputs

| Output | Description |
|--------|-------------|
| `app_url` | Public URL of the internet-facing ALB — open in browser or curl |

```bash
terraform output app_url
curl $(terraform output -raw app_url)
```

---

## Cleanup

```bash
terraform destroy -var-file=dev.tfvars
```

This removes all provisioned resources including both VPCs, the Transit Gateway, all load balancers, the ECS cluster, Aurora cluster, and associated IAM and networking resources.

---

## Scheduled Job Recommendation

To fetch new stories from `https://hacker-news.firebaseio.com` every day at 5am GMT+8 and store them into the database, I would recommend using **EventBridge Scheduler + AWS Lambda** due to the following reasons.
- Lambda is serverless which means there is no idle compute cost and billed only for execution duration.
- Simpler to deploy without needing any task definition, cluster, or container image management
- EventBridge Scheduler natively supports cron expressions and handles retries

---

## AI Usage

Claude and Cursor were used as coding assistants throughout this project for:
- Explaining AWS networking concepts
- Explaining Terraform concepts
- Reviewing and improving Terraform module structure
- Identifying and fixing bugs