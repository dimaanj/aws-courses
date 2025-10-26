# Network Concepts Explained

This document explains the networking concepts used in this Terraform project from a software engineer's perspective.

## Table of Contents
1. [What is VPC?](#what-is-vpc)
2. [Subnets Explained](#subnets-explained)
3. [Public vs Private Subnets](#public-vs-private-subnets)
4. [Internet Gateway](#internet-gateway)
5. [NAT Gateway](#nat-gateway)
6. [Route Tables](#route-tables)
7. [Security Groups](#security-groups)
8. [CIDR Notation](#cidr-notation)
9. [Availability Zones](#availability-zones)
10. [Data Flow Examples](#data-flow-examples)

## What is VPC?

**VPC (Virtual Private Cloud)** is like creating your own isolated network within AWS - think of it as your own data center.

### Key Points:
- **Isolation**: Resources in your VPC are isolated from other AWS accounts' VPCs
- **Customizable**: You define the IP address range (CIDR block)
- **Regional**: Each VPC is created in a specific AWS region
- **DNS**: Can enable DNS hostnames and DNS resolution for resources

### In This Project:
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"  # 65,536 IP addresses
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

**Real-world analogy**: Like renting a floor in an office building where you control the entire space.

## Subnets Explained

A **subnet** is a segment of your VPC's IP address range. It's like dividing your office floor into different rooms.

### Key Points:
- **Isolation**: Each subnet is in one Availability Zone (data center location)
- **Logical Grouping**: Resources in a subnet can communicate easily
- **Resource Placement**: You choose which subnet each resource lives in

### In This Project:
- **Public Subnets**: 10.0.0.0/24 and 10.0.1.0/24 (256 IPs each)
- **Private Subnets**: 10.0.10.0/24 and 10.0.11.0/24 (256 IPs each)

**Real-world analogy**: Different departments in your company - some need to face customers (public), others need to be hidden (private).

## Public vs Private Subnets

### Public Subnets
- **Auto-assigned Public IPs**: Instances get public IP addresses
- **Direct Internet Access**: Can talk to the internet directly
- **Use Cases**: Load balancers, NAT gateways, bastion hosts

### Private Subnets
- **No Public IPs**: Instances don't get public IPs automatically
- **Indirect Internet Access**: Can reach internet via NAT Gateway
- **Use Cases**: Application servers, databases, internal services

### Why This Matters?
```
User → Internet Gateway → Public Subnet → Load Balancer
                                                ↓
                                      Private Subnet → Your App
```

**Security benefit**: Your application servers never expose their IPs to the internet, making them harder to attack directly.

## Internet Gateway

An **Internet Gateway (IGW)** is the doorway between your VPC and the internet.

### What It Does:
- **Two-way traffic**: Allows both inbound and outbound internet traffic
- **NAT Translation**: Translates public IPs to private IPs and vice versa
- **Scalable**: Automatically scales to handle all traffic

### In This Project:
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```

**Real-world analogy**: The main entrance of your office building where guests and employees enter/exit.

## NAT Gateway

**NAT (Network Address Translation) Gateway** allows private subnets to make outbound internet connections without allowing inbound connections.

### Key Differences from Internet Gateway:
- **One-way**: Only allows outbound traffic
- **No Inbound**: Cannot directly reach instances from the internet
- **Cost**: There's a small hourly charge for using NAT Gateways
- **High Availability**: Should create one per Availability Zone

### Why You Need It:
Imagine your application needs to:
- Call external APIs (like payment processors, email services)
- Download updates
- Make outbound database connections

But you DON'T want it directly accessible from the internet. NAT Gateway solves this!

### In This Project:
```hcl
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat[count.index].id  # Needs a public IP
  subnet_id     = aws_subnet.public[count.index].id  # Lives in public subnet
}
```

**Real-world analogy**: A secure exit door - you can leave the building, but strangers can't come in the same way.

## Route Tables

**Route Tables** are like signposts that tell network traffic which path to take.

### How It Works:
Each subnet needs a route table that defines:
- "Where should traffic go when heading to 0.0.0.0/0 (the internet)?"
- "Where should traffic go when heading to other subnets in this VPC?"

### Public Subnet Route Table:
```
Destination          Target
10.0.0.0/16         local (stays in VPC)
0.0.0.0/0           internet-gateway (goes to internet)
```

### Private Subnet Route Table:
```
Destination          Target
10.0.0.0/16         local (stays in VPC)
0.0.0.0/0           nat-gateway (goes to internet via NAT)
```

### In This Project:
```hcl
# Public routes
resource "aws_route_table" "public" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Private routes
resource "aws_route_table" "private" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
}
```

**Real-world analogy**: Like GPS routing - tells your data "take this route to reach your destination."

## Security Groups

**Security Groups** are like firewalls that control what traffic can enter and leave your resources.

### Key Concepts:
- **Stateful**: If you allow inbound traffic, the response is automatically allowed out
- **Firewall at Instance Level**: Each instance can have multiple security groups
- **Deny by Default**: Only explicitly allowed traffic gets through
- **Allow Rules Only**: You can't create "deny" rules

### Two Types of Rules:

#### Ingress (Incoming Traffic)
```hcl
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # From anywhere
}
```

#### Egress (Outgoing Traffic)
```hcl
egress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # To anywhere
}
```

### Security Group Referencing
Instead of using IP addresses, you can reference other security groups:
```hcl
ingress {
  description     = "Allow HTTP from ALB"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.elb.id]  # Only from ELB
}
```

**Real-world analogy**: Like a bouncer at a club - they check who's trying to enter and only let in the right people.

## CIDR Notation

**CIDR (Classless Inter-Domain Routing)** is how we express IP address ranges.

### The Format:
```
192.168.1.0/24
    ↓      ↓
   IP    Prefix
         Length
```

### How to Read It:
- **10.0.0.0/16**: 10.0.0.0 to 10.0.255.255 (65,536 addresses)
- **10.0.0.0/24**: 10.0.0.0 to 10.0.0.255 (256 addresses)
- **0.0.0.0/0**: All IP addresses (the entire internet)

### Common Prefix Lengths:
- **/32**: Single IP (e.g., 192.168.1.100/32)
- **/24**: 256 IPs (e.g., 192.168.1.0/24)
- **/16**: 65,536 IPs (e.g., 10.0.0.0/16)
- **/8**: 16,777,216 IPs (e.g., 10.0.0.0/8)
- **/0**: Everything

**Real-world analogy**: Like house numbers - "/24" means you're in the same neighborhood block.

## Availability Zones

**Availability Zones (AZs)** are isolated data centers within an AWS region.

### Key Points:
- **Physical Separation**: Each AZ is physically separated from others
- **Multiple AZs**: Most regions have 2-6 AZs
- **High Availability**: Deploy resources across AZs for fault tolerance
- **Low Latency**: AZs within a region can communicate with low latency

### In This Project:
```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

# Spread subnets across AZs
availability_zone = data.aws_availability_zones.available.names[0]  # AZ-a
availability_zone = data.aws_availability_zones.available.names[1]  # AZ-b
```

**Real-world analogy**: Multiple branches of your company in different locations of the same city.

### Why It Matters:
If one data center has a power outage, your application in another AZ keeps running!

## Data Flow Examples

### Example 1: User Visiting Your Website

```
1. User types website URL (e.g., https://myapp.com)
   ↓
2. DNS resolves to ALB public IP
   ↓
3. Traffic hits Internet Gateway
   ↓
4. Routes to Public Subnet (via public route table)
   ↓
5. ALB (in public subnet) receives request
   ↓
6. ALB Security Group allows port 443
   ↓
7. ALB forwards to Web Server in Private Subnet
   ↓
8. Web Server Security Group allows from ALB SG
   ↓
9. Web Server processes request
   ↓
10. Response follows same path back
```

### Example 2: Web Server Calling External API

```
1. Web Server needs to call external API (e.g., payment service)
   ↓
2. Request goes from Private Subnet
   ↓
3. Route table says: "0.0.0.0/0 → NAT Gateway"
   ↓
4. Traffic hits NAT Gateway in Public Subnet
   ↓
5. NAT Gateway translates private IP to public IP
   ↓
6. Traffic goes through Internet Gateway
   ↓
7. Reaches external API on the internet
   ↓
8. Response comes back via same path
```

### Example 3: Direct SSH to Instance (BLOCKED!)

```
1. Attacker tries to SSH directly to instance IP
   ↓
2. Traffic hits Internet Gateway
   ↓
3. Route table in Private Subnet has no route back!
   ↓
4. ❌ FAIL - Cannot reach private subnet from internet
   ✅ Your instances are protected!
```

## Best Practices

### 1. Always Use Private Subnets for Application Servers
- **Don't**: Put web servers in public subnets
- **Do**: Put them in private subnets

### 2. Use Security Group References
- **Don't**: Allow traffic from specific IP addresses
- **Do**: Allow traffic from other security groups

```hcl
# Bad ❌
ingress {
  cidr_blocks = ["203.0.113.12/32"]  # Specific IP
}

# Good ✅
ingress {
  security_groups = [aws_security_group.frontend.id]
}
```

### 3. Deploy Across Multiple AZs
- **Don't**: Put all resources in one AZ
- **Do**: Spread resources across at least 2 AZs

### 4. Use Least Privilege
- **Don't**: Allow all outbound traffic (`0.0.0.0/0` on all ports)
- **Do**: Only allow specific ports and protocols

```hcl
# Bad ❌
egress {
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# Good ✅
egress {
  description = "Allow HTTPS only"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

## Common Pitfalls

### 1. Forgetting Route Table Associations
Resources are created but can't reach the internet:
```bash
# Missing this!
aws_route_table_association (not created)
```

### 2. Putting NAT Gateway in Private Subnet
NAT Gateway MUST be in public subnet:
```hcl
# Wrong ❌
subnet_id = aws_subnet.private[count.index].id

# Correct ✅
subnet_id = aws_subnet.public[count.index].id
```

### 3. Circular Security Group Dependencies
```hcl
# Security Group A allows from B
# Security Group B allows from A
# Both allowing from each other creates a loop!
```

### 4. Forgetting Elastic IP for NAT Gateway
```hcl
# Wrong ❌ - NAT Gateway without EIP
resource "aws_nat_gateway" "main" {
  subnet_id = aws_subnet.public[count.index].id
}

# Correct ✅
resource "aws_eip" "nat" {
  domain = "vpc"
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}
```

## Summary

| Concept | What It Does | Where It Lives |
|---------|-------------|----------------|
| **VPC** | Your isolated network | Regional |
| **Internet Gateway** | Direct internet access | Attached to VPC |
| **NAT Gateway** | One-way internet access | Public Subnet |
| **Public Subnet** | Internet-facing resources | Multiple AZs |
| **Private Subnet** | Isolated resources | Multiple AZs |
| **Route Table** | Traffic routing rules | Per subnet |
| **Security Group** | Firewall rules | Per resource |

## Quick Reference

### Network Diagram
```
Internet
    ↓
Internet Gateway (Direct Access)
    ↓
Public Subnet (AZ-1a)
├── NAT Gateway 1
└── NAT Gateway EIP 1
    ↓
Private Subnet (AZ-1a)
├── Web Server
├── TCP Service
└── UDP Service

Internet
    ↓
Internet Gateway (Direct Access)
    ↓
Public Subnet (AZ-1b)
├── NAT Gateway 2
└── NAT Gateway EIP 2
    ↓
Private Subnet (AZ-1b)
├── Web Server
├── TCP Service
└── UDP Service
```

This architecture provides:
- ✅ **High Availability** (across AZs)
- ✅ **Security** (isolated subnets)
- ✅ **Scalability** (can add more subnets)
- ✅ **Internet Access** (via NAT Gateway)
- ✅ **Protection** (security groups)

---

**Next Steps**: Check out the `README.md` file for setup instructions, or look at the Terraform code files to see how these concepts are implemented.

