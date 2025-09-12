# InternalBlogWebsite
This repository contains Design of our Internal Blog Website. It contains code for the infrastructure as well. 




**Approach 1:** Using AKS as hosting platform for all the workloads.
<img width="1312" height="550" alt="image" src="https://github.com/user-attachments/assets/c3339d40-e1b3-4148-8f12-e017603e155e" />

**Components**:
1) Azure Kubernetes Service - Hosting platform
2) Azure Application Gateway - Security And Routing
3) Network Security Group - Firewall based on IP range and Port
4) Azure Key Vault - To store Infra and app secrets
5) Azure VNET - Private network
6) Azure Subnet
7) Private End Point - To connect PAAS resources to Azure Virtual Network
8) Azure SQL server - To store User information, Blog related data, User Comments, Chats 
9) Azure Blob Storage Account - To store Images and Videos related to Blog
10) Redis Cache - To cache data to reduce latency.

**System Design: (HLD)**
1) Application Gateway serves as the secure entry point for end users. It not only routes traffic to the backend services but also functions as a Web Application Firewall (WAF), protecting the application by blocking malicious traffic. We will set OWASP standard rules. Once we test the application we can exclude some of the rules if required.
2) The Application Gateway is configured with a frontend Public IP and secured using a Custom V2 SSL policy. The policy enforces strong cipher suites and sets the minimum TLS version to 1.2, in line with Microsoft’s security best practices. Also a TLS certificate needs to be attached with Custom Domain Name.
3) The Application Gateway is integrated with the Virtual Network through a dedicated subnet, secured by a Network Security Group (NSG). The NSG acts as a traffic filter, allowing only required inbound and outbound traffic while blocking unauthorized access, thereby adding an extra layer of network-level security.
4) The Application Gateway backend pool is connected to the AKS Ingress Load Balancer. Traffic reaching the cluster is then routed by the Ingress Controller based on path-based rules, ensuring requests are directed to the correct microservice.
5) The AKS cluster is deployed with Linux node pools using D4as_v5 VM size and backed by Virtual Machine Scale Sets (VMSS) for high availability and autoscaling.Also the noodepool setting will be in autoscale mode with min 1 and Max 10 Nodes. 
6) The cluster is connected to a dedicated subnet and a NSG within the same Virtual Network as the Application Gateway for secure and seamless communication. All internal service-to-service communication inside the cluster happens through ClusterIP, providing stable virtual IPs for workloads. Session affinity can be enabled to ensure that repeated client requests are routed to the same pod, which is essential for stateful applications.
7) 
