# Multi-Tier Load Balancer - Key Concepts for Software Engineers

## 🎯 TL;DR - What This Architecture Does

```
Internet → ALB (routes by URL path) → Web Servers → NLB (routes by protocol) → Backend Services
```

You get:
- **High Availability**: Multiple instances per tier
- **Security**: Private backends, public fronts
- **Scalability**: Auto-scale each tier independently
- **Flexibility**: Use different protocols (TCP/UDP) for different needs

---

## 🧠 Core Concepts Explained

### 1. Load Balancer Types (The Big Difference)

**Application Load Balancer (ALB)** - "The Smart Router"
```javascript
// ALB inspects HTTP content
if (request.path === '/customers') {
    return customersWebServer;
} else if (request.path === '/orders') {
    return ordersWebServer;
}
```

**Network Load Balancer (NLB)** - "The Fast Router"
```javascript
// NLB only looks at ports
if (packet.port === 8080 && packet.protocol === 'TCP') {
    return tcpBackendService;
} else if (packet.port === 8443 && packet.protocol === 'UDP') {
    return udpBackendService;
}
```

**When to use what:**
- ALB: When routing depends on **WHAT** the user is requesting
- NLB: When routing depends on **HOW** the data is sent (protocol/port)

---

### 2. Subnet Isolation (Public vs Private)

Think of it like your company office:

```
Public Subnet = Reception Area
├─ Anyone can walk in
├─ Receptionists (Web Servers) handle initial contact
└─ They can talk to the private area

Private Subnet = Back Office
├─ Only accessible via reception
├─ Contains sensitive data and systems
└─ No direct internet connection
```

**Security Benefits:**
- **Attack Surface Reduction**: Backend services invisible to internet
- **Data Protection**: Private subnet = private data
- **Regulatory Compliance**: Meets requirements for data isolation

---

### 3. Security Groups as Firewalls

Every EC2 instance gets its own "firewall rules":

```terraform
# Web Server Security Group
Rules:
  ✓ Allow inbound from ALB on HTTP port
  ✗ Deny inbound from internet directly
  ✗ Deny inbound from backend services
  ✓ Allow outbound to NLB

# Backend Service Security Group  
Rules:
  ✓ Allow inbound from NLB only
  ✗ Deny all internet access
  ✗ Deny direct access from web servers
```

This is **micro-segmentation** - every service has its own security boundary.

---

### 4. Target Groups = Load Balancer Backend Pools

```javascript
// Target Group is like a pool of workers
const customersTargetGroup = {
    instances: [ws1, ws2, ws3],  // Multiple web servers
    healthCheck: '/health',       // How to check if healthy
    port: 80,                     // Which port to use
    protocol: 'HTTP'              // What protocol
};

// Load balancer distributes work like:
function getHealthyInstance(targetGroup) {
    const healthy = targetGroup.instances.filter(i => i.isHealthy);
    return roundRobin(healthy);  // Distribute evenly
}
```

**Why Multiple Instances in Each Group?**
- **Redundancy**: If one dies, others handle traffic
- **Load Distribution**: Spread requests across instances
- **Auto-Scaling**: Add/remove instances based on load

---

### 5. Listener Rules & Priority (The Router Logic)

```terraform
# This is essentially a router configuration
Listener Rules (evaluated top to bottom):

Priority 100: IF path = '/customers'   THEN forward to customers
Priority 200: IF path = '/orders'      THEN forward to orders
Priority 999: IF path = '/*'           THEN redirect to /orders
```

This mirrors web framework routing:
```javascript
// Express.js equivalent
app.get('/customers', customersHandler);    // Priority 100
app.get('/orders', ordersHandler);          // Priority 200
app.get('/*', (req, res) => {               // Default (999)
    res.redirect('/orders');
});
```

---

### 6. Why Both TCP and UDP for Backend?

**TCP (Transmission Control Protocol):**
```javascript
// Reliable, ordered, connection-oriented
const response = await fetch('http://backend/api/orders', {
    method: 'POST',
    body: JSON.stringify(orderData)
});
// You NEED a response - confirmed delivery
```

Use for: Database queries, API calls, file transfers, transactions

**UDP (User Datagram Protocol):**
```javascript
// Fast, best-effort, connectionless
socket.send(metrics, backend, port);
// You send it and hope it arrives - don't wait
```

Use for: Metrics, logging, streaming, real-time data

**Why Both in Architecture?**
```javascript
// Your application might need both
class WebServer {
    async handleOrder(order) {
        // Critical data - use TCP for reliability
        await this.tcpClient.post('/api/orders', order);
        
        // Metrics - use UDP for performance
        this.udpClient.send('metric:order.created');
    }
}
```

---

### 7. Health Checks = Automatic Failure Detection

```javascript
// How health checks work conceptually
class TargetGroup {
    async healthCheck(instance) {
        const response = await fetch(`http://${instance.ip}:${healthPort}/health`);
        
        if (response.status === 200) {
            instance.markHealthy();
        } else {
            instance.markUnhealthy();
            this.removeInstance(instance);  // Stop sending traffic
        }
    }
    
    checkHealth() {
        setInterval(() => {
            this.instances.forEach(instance => {
                this.healthCheck(instance);
            });
        }, 30);  // Every 30 seconds
    }
}
```

**Benefits:**
- **Self-healing**: Automatically removes broken instances
- **Zero-downtime deployments**: Add new instances, remove old ones
- **Proactive monitoring**: Detect issues before users do

---

### 8. Architecture Patterns Applied

#### **Reverse Proxy Pattern**
```
User → [ALB] → Web Server → [NLB] → Backend
       ^                         ^
       └─ Masks complexity       └─ Masks complexity
```
Benefits: Hide internal structure, centralize SSL, add caching

#### **Circuit Breaker Pattern**
```
If (instance.isUnhealthy) {
    circuit.open();  // Stop sending requests
    // Wait for instance to recover
    // If recoverable, circuit.close()
}
```

#### **Blue-Green Deployment Support**
```
Blue:  Old version running
Green: New version running
NLB:   Can route traffic gradually from blue to green
```

---

### 9. Terraform Resource Lifecycle

When you run `terraform apply`:

```javascript
// Step 1: Plan (dry-run)
plan = terraform.plan();
/*
  - Create: 4 target group attachments
  - Create: 1 ALB listener
  - Create: 2 NLB listeners
  - Create: 3 listener rules
*/

// Step 2: Apply (actual changes)
terraform.apply();
/*
  For each resource:
  1. Check current state
  2. Compare to desired state
  3. Determine changes needed
  4. Apply changes in dependency order
  5. Update state file
*/

// Step 3: State Management
state = {
    target_groups: {...},
    listeners: {...},
    rules: {...}
};
// This allows:
// - Rollback on failure
// - Idempotent operations (safe to run multiple times)
// - Change tracking
```

---

### 10. Real-World Use Cases

**E-commerce Site:**
```
ALB routes:
  /products → Product catalog microservice
  /cart     → Shopping cart microservice
  /payment  → Payment processing service

Backend services (NLB):
  TCP:  Critical operations (place order, payment)
  UDP:  Real-time inventory updates, analytics
```

**Microservices Architecture:**
```
ALB:  Gateway API - routes to microservices
Web:  API Gateway instances (Node.js, Python, etc.)
NLB:  Internal service mesh
Backend: Individual microservices (user-service, order-service, etc.)
```

---

## 🚀 How to Think About This Architecture

### As a Software Engineer, Think of It As:

```
┌─────────────────────────────────────────────┐
│  ALB     = Nginx/Apache at app entry point  │
├─────────────────────────────────────────────┤
│  Web     = Your application servers         │
│  Servers = (Node.js, Python, Java, etc.)    │
├─────────────────────────────────────────────┤
│  NLB     = Internal load balancer/router    │
├─────────────────────────────────────────────┤
│  Backend = Database, cache, other services  │
└─────────────────────────────────────────────┘
```

This is essentially:
- **ALB** = Your API Gateway
- **Web Servers** = Your application code
- **NLB** = Your service mesh/router
- **Backend Services** = Your microservices or database layer

---

## 🎓 Key Takeaways

1. **Layer 7 (ALB)** inspects HTTP content for routing decisions
2. **Layer 4 (NLB)** inspects only ports/protocols for speed
3. **Private subnets** = security isolation for sensitive data
4. **Target groups** = dynamically manageable backend pools
5. **Security groups** = per-service firewall rules
6. **Health checks** = automatic failure detection and recovery
7. **Terraform** = infrastructure as code for repeatability

This architecture gives you **enterprise-grade scalability, security, and reliability** - all managed with Infrastructure as Code.

