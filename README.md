# InternalBlogWebsite
This repository contains Design of our Internal Blog Website. It contains code for the infrastructure as well. 




**Approach 1:** Using AKS as hosting platform for all the workloads.
<img width="1097" height="470" alt="image" src="https://github.com/user-attachments/assets/3e66482a-0faf-4fdc-815f-2973c9bb4583" />


**Components**:
1) Azure Kubernetes Service - Hosting platform
2) Azure Application Gateway - Security and routing
3) Network Security Group - Layer 4 Firewall
4) Azure Key Vault - To store infra and app secrets
5) Azure VNET - Private network
6) Azure Subnet
7) Private End Point - To connect PAAS resources to Azure Virtual Network
8) Azure SQL server - To store User information, Blog related data, User Comments, Chats 
9) Azure Blob Storage Account - To store Images and Videos related to Blog
10) Redis Cache - To cache data to reduce latency.

**System Design: (HLD)**
1) The application infra is hosted across 3 Resource groups for better grouping of resources and access control at RG level.
 - RG1 contains network services including vnet, subnet, application gateway, publicIP, Network security group.
 - RG2 contains AKS, aksnodes, log analytics.
 - RG3 contains sql server, sql DB, storage account, keyvaut, redisCache, private endpoints for all the mentioned resources. etc
2) Each subnet is protected with dedicated Network Security Groups (NSGs) to ensure secure traffic flow:
   - Subnet 1 – dedicated to the Application Gateway.
   - Subnet 2 – hosts AKS and its components.
   - Subnet 3 – reserved for data services such as SQL Server, Storage Account, and Redis.
3) End-users access the application through a frontend public IP that is mapped to a custom DNS. The Application Gateway forwards traffic to the AKS ingress controller, which serves as the entry point for workloads running in the cluster
4) The ingress controller routes requests to the appropriate AKS workloads based on the incoming traffic rules. Since AKS is integrated with the VNet, the APIs are never exposed directly to the internet, ensuring that all communication remains securely within the VNet.
5) There are 3 app workloads in AKS,
     A) UserAuthentication
     B) BlogCreation/Approval
     C) Comments/Chat
6) User information, blog content, and comments/chat data are stored in Azure SQL Database, while images and videos are securely stored in Azure Blob Storage
7) All data services are integrated with the VNet using private endpoints, ensuring that communication between AKS and the data services remains private and fully secured.
8) Azure Redis Cache is used alongside SQL Server and Blob Storage through private endpoints. Redis improves performance with low latency, in-memory access for frequently used data, while SQL Server handles relational data and Blob Storage manages large unstructured content (multimedia).
9) Initial Phase (50 users) – Run with a fixed capacity of 1 node in the system pool and 2 nodes in the application pool, which is cost-efficient for low traffic and helps establish baseline CPU/memory utilization.
10) Scaling Phase (growth beyond 50 users) – Enable Cluster Autoscaler (min 1, max 15 nodes) and configure Horizontal Pod Autoscaler (HPA) in application manifests. This ensures the cluster scales dynamically based on demand, optimizing both performance and cost.
11) Connection strings of Azure resources are stored securely in Key Vault. The application manifests reference these secrets, and during the CD pipeline run, the secrets are fetched from Key Vault and injected into the placeholders.
12) Logging is enabled using log analytics agent on AKS, this help us to troubleshoot any possible issue. Also additionally we can set alerts based on the logs as well.

**Deploy Infrastructure Pipeline:**

Deploy infrastructure pipeline templates does the following, 
1) Create terraform backend infra (Backend storage account, Resource group, storage container) to store state file.
2) Terraform init inside infra working directory where our root terraform file exists.
3) We have set a DryRun parameter, on being true this executes only terraform plan, A user can validate his changes and then set DryRun param to false to actually apply the changes
4) With this the entire infrastructure would be provsioned and it maintains desired state always.
5) The application infrastructure is modularized into 4 modules,
   - network module - contains resources like vnet, subnet, NSGs
   - appgw module - contains application gateway, publicIP for app gateway
   - aks module - aks, log analyics workspace
   - data_services - SQL server, SQL DB, Blob Storage account, Redis Cache, Private endpoints and Private DNS zones.

**Application Workloads Development Lifecycle:**


<img width="916" height="513" alt="image" src="https://github.com/user-attachments/assets/544367aa-3b99-400a-b1b1-bf3dacc857bd" />

1) Each microservices has 2 repositories, a) Product Code repo b) Product config repo ( Kubernetes Manifest files for microservcies)
2) Advantages of maintaining 2 repos for microservices:
   - Independent Lifecycles - We can release minor hotfixs individualy without affecting other repos and can avoid regulatory steps if        its a config change.
   - GitOps Friendly - The manifest repo becomes the source of truth for the cluster state.
   - Versioning & Rollbacks
4) A CI pipeline wil run against product code which does below tasks:
   - Build code, Run Unit tests
   - Run Sonar Analysis, checkmarx scan ( These 2 steps can be considered as Pre-CI)
   - Build Dockerfile to create docker image, runs whitesource security scan on the built image and pushes image  to container registry.
   - Publishes checksum and build number as artefact 
5) A CD pipeline will run against config repo, this CD pipeline will use artefact from CI pipeline. Also it does below tasks:
   - Gets secrets from key Vault
   - Kube login
   - Compare Checksum from CI against registry to check integrity of the image
   - Deploy Manifest files using kubectl apply.
   - The manifest will contain latest Build number of image which will be pulled by AKS from ACR.
