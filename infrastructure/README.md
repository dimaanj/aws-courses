# Application Infrastructure

This project deploys the application layer of the multi-tier architecture:
- Load Balancers (ALB and NLB)
- Target Groups
- EC2 Instances (Web servers and backend services)
- Listeners and Routing Rules

**This project depends on the [network](../network/) project being deployed first.**

## Architecture

```
Network Project (Prerequisite)
├── VPC with Public/Private Subnets
├── NAT Gateways
└── Security Groups

Application Project (This Project)
├── Application Load Balancer
├── Network Load Balancer
├── Target Groups
├── EC2 Instances
└── Listeners & Rules
```

## Prerequisites

1. Network project must be deployed first
2. Network outputs must be available in `../network/terraform.tfstate`

## Setup

1. Navigate to network directory and deploy:
   ```bash
   cd ../network
   terraform init
   terraform apply
   cd ../infrastructure
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Configure variables (create terraform.tfvars):
   ```hcl
   project_name = "multi-tier-app"
   instance_type = "t3.micro"
   ```

4. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Outputs

```bash
# Get the ALB DNS name
terraform output customers_url

# Get all URLs
terraform output
```

## What Gets Created

- 2 Load Balancers (ALB + NLB)
- 4 Target Groups
- 4 EC2 Instances
- 4 Target Group Attachments
- 3 Listeners
- 2 Listener Rules

## Dependencies

This project references:
- VPC ID from network project
- Subnet IDs from network project
- Security Group IDs from network project

All referenced via Terraform remote state.

## Destruction

Destroy in reverse order:
```bash
terraform destroy  # Destroy application layer first
cd ../network
terraform destroy # Then destroy network layer
```

