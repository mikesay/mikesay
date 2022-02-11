## Application Gateway Ingress Controller
Cotainer Native Load balancing (NEG)
https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing


## Map Cloud IAM to Kubernetes Service Accounts
WorkLoad Indentity (WLI)  
https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity


## Dive into GKE

### Maximum node support
GKE 2020: 15000
GKE before 1.8: 5000
Others Kubernetes: 5000

### Autoscaling
Predictive autoscaling

Autopilot (Node is invisible)

### Log and monitoring
Stackdriver

### Network
Advance routing
Alias IP

### Global Load Balancer
+ Anycast EIP GFE

+ DSN method: www.myapp.com/120.1.0.1, disatavantage: TTL

### Gateway
NEG

### Anthos
TBD

### Istio (ASM)
Istio resources can also be deployed in customer's Kubernetes