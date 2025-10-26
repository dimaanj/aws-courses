# Multi-Tier Application Architecture

## Traffic Flow

```
Internet (External)
    ↓
Application Load Balancer (ALB) [Security Group: elb_sg]
    ↓
    ├─ /customers → Customers web server (tcp_client_instance_id) [Security Group: webserver_sg]
    │                    ↓
    │                    ├─ TCP traffic → Network LB (internal)
    │                    └─ UDP traffic → Network LB (internal)
    │
    └─ /orders → Orders web server (udp_client_instance_id) [Security Group: webserver_sg]
                     ↓
                     ├─ TCP traffic → Network LB (internal)
                     └─ UDP traffic → Network LB (internal)
                     
                           Network LB (internal) [Security Group: elb_sg]
                           ↓
                           ├─ TCP Listener (port: tcp_port)
                           │   └─ TCP Traffic → Backend Services
                           │       ├─ → Customers service (tcp_server_instance_id) [Security Group: tcpserver_sg]
                           │       └─ → Orders service (udp_server_instance_id) [Security Group: udpserver_sg]
                           │
                           └─ UDP Listener (port: udp_port)
                               └─ UDP Traffic → Backend Services
                                   ├─ → Customers service (tcp_server_instance_id) [Security Group: tcpserver_sg]
                                   └─ → Orders service (udp_server_instance_id) [Security Group: udpserver_sg]
```

## Configuration Summary

### 1. Target Group Attachments (ALB)
- **Customers target group** → Attached to: `tcp_client_instance_id` (Customers web server)
- **Orders target group** → Attached to: `udp_client_instance_id` (Orders web server)

### 2. Target Group Attachments (NLB)
- **TCP servers target group** → Attached to:
  - `tcp_server_instance_id` (Customers service)
  - `udp_server_instance_id` (Orders service)
  
- **UDP servers target group** → Attached to:
  - `tcp_server_instance_id` (Customers service)
  - `udp_server_instance_id` (Orders service)

### 3. ALB Listener Rules
- **Priority 100**: Path `/customers` → Forwards to Customers target group
- **Priority 200**: Path `/orders` → Forwards to Orders target group
- **Default**: All other paths → Redirects to `/orders` with HTTP 302

### 4. NLB Listeners
- **TCP Listener** (port: `tcp_port`) → Forwards to TCP servers target group
- **UDP Listener** (port: `udp_port`) → Forwards to UDP servers target group

## Key Points

1. Both web servers send **both TCP and UDP traffic** to the NLB
2. Both backend services receive **both TCP and UDP traffic** from the NLB
3. The ALB provides path-based routing to web servers
4. The NLB provides protocol-based routing to backend services
5. All components have dedicated Security Groups

