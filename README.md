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
1) The application infra is hosted across 3 Resource groups.
2) RG1 contains network services including vnet, subnet, application gateway, publicIP, Network security group.
3) RG2 contains AKS, aksnodes, log analytics.
4) RG3 contains sql server, sql DB, storage account, keyvaut, redisCache, private endpoints for all the mentioned resources. etc
5) The resources are secured with NSGs on each of the subnet.
   a) subnet 1: For App gateway
   b) subnet 2: For Aks and its components.
   c) subnet 3: For Data services like, sql server, storage account, redis.
6) The endUser access application through frontend Public IP which is configured with custom DNS. Application gateway's backend is connected to Ingress of AKS resource.
7) Based on the incoming request ingress routes the traffic to appropriate workload of AKS. Since AKS is also enabled with Vnet integration the APIs are never exposed to internet. The communication always occurs inside Vnet.
8) There are 3 app workloads in AKS,
     A) UserAuthentication
     B) BlogCreation/Approval
     C) Comments/Chat
9) For storing user information, Blog text data, comments/chat data we have SQL server while the images/video are stored in blob storage.
10) The data services are also integrated with vnet using private endpoints. So the communication between AKS and Data services is secured.
11) We also have redis cache, the same endpoint should be used in application code to read/write data on data services.
12) During the intial phase where we have only 50 users, we can have fixed number of nodes of 1 for system Pool and 2 nodes for app Pool.
    During this phase we can check figure out CPU/memory metrics required to serve this load. Then we can start configuring clusterAuto scaled setting in which min_node count is set to 1 ad max can be set to 15. Also we can enable HPA based on cpu/memory metric in app manifest files.
13) To increase security we can also use Manged identity in future.(Not included as part of this design). Here we are using connection strings which will be stored in keyVault. And App manifest files will contain references to these secrets. And during CD pipeline run the secrets are pulled and replace in place holder.
14) Logging is enabled using log analytics agent on AKS, this help us to troubleshoot any possible issue. Also additionally we can set alerts based on the logs as well.
15) In future we can start monitoring other azure reosurce as well. To reduce cost we can introduce some open source monitoring tools like opentelemetry.
