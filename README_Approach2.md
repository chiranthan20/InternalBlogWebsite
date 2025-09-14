# InternalBlogWebsite
This repository contains Design of our Internal Blog Website. It contains code for the infrastructure as well. 

**Approach 2: Use Multiple Hosting platform.**

<img width="1082" height="403" alt="image" src="https://github.com/user-attachments/assets/4fc12667-f94a-46da-b466-81100676e957" />

**Components:**

1) Azure Kubernetes Service - Hosting platform for Blog Workload
2) Azure App Service - Hosting platform for User Management Workload
3) Azure Virtual Machine - Hosting Platform for Chat/Comment Workload
4) API Management service - rate limit, caching and Routing
5) Azure Application Gateway - Security and routing
6) Network Security Group - Layer 4 Firewall
7) Azure Key Vault - To store infra and app secrets
8) Azure VNET - Private network
9) Azure Subnet
10) Private End Point - To connect PAAS resources to Azure Virtual Network
11) Azure SQL server - To store User information, Blog related data, User Comments, Chats 
12) Azure Blob Storage Account - To store Images and Videos related to Blog
13) Redis Cache - To cache data to reduce latency.


**System Design: (HLD)**

1) The application infra is hosted across 3 Resource groups for better grouping of resources and access control at RG level.
 - RG1 contains network services including vnet, subnet, application gateway, publicIP, Network security group.
 - RG2 contains AKS, aksnodes, log analytics, App Service, Virtual Machine, API Management service
 - RG3 contains sql server, sql DB, storage account, keyvaut, redisCache, private endpoints for all the mentioned resources. etc
2) Each subnet is protected with dedicated Network Security Groups (NSGs) to ensure secure traffic flow:
   - Subnet 1 – dedicated to the Application Gateway.
   - Subnet 2 – hosts AKS and its components.
   - Subnet 3 – reserved for data services such as SQL Server, Storage Account, and Redis.
3) The workloads are hosted across App Service, AKS and VM,
   - User Authentication (A) → App Service Plan: Authentication workloads are stateless and mainly deal with API endpoints + integrations with identity providers (AAD, OAuth, etc.).
   - Blog Creation / Approval (B) → AKS (Kubernetes): This is the core business workload and may require scalability, rolling updates, and high availability.
   - Comments / Chat (C) → Virtual Machines (VMs): Chat workloads can be stateful with persistent connections (WebSockets, custom messaging).
4) End-users access the application through a frontend public IP that is mapped to a custom DNS. The Application Gateway forwards traffic to the API Management service, which serves as the single entry point for workloads running in the different hosting platforms.
5) While App Gateway will handle TLS termination, WAF, and public DNS exposure. All traffic from App Gateway is forwarded to APIM (private or internal VNet integrated endpoint) which does the routing.
6) Routing in APIM can be configured using below steps:
  - Create API and assign right backend for each of the APIs.
  - Define Operation and Routing, like below
     User API (App Service)
     /user/login → forwards to /api/login in App Service
     /user/register → forwards to /api/register
     Blog API (AKS)
     /blog/create → forwards to /api/create in AKS
     /blog/approve → forwards to /api/approve
     Chat API (VM)
     /chat/send → forwards to /sendMessage on VM
     /chat/history → forwards to /getHistory
7) Policies in APIM allow you to transform requests/responses, secure, and route more flexibly.
8) Once the traffic reached the right workload it serves the api call accordingly, if required it reaches data services through secure ways like in approach1.

