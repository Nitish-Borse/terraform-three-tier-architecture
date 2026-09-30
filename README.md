# Terraform AWS Three-Tier Architecture

A hands-on Terraform project that provisions a three-tier architecture
on AWS using reusable Terraform modules.

The infrastructure is divided into:

-   **Web tier** --- Public subnet with a public EC2 instance
-   **Application tier** --- Private subnet with an EC2 instance without
    a public IP
-   **Database tier** --- Private subnets with Amazon RDS for MySQL
-   **Network layer** --- VPC, Internet Gateway, route tables, NAT
    Gateway, and Elastic IP
-   **Security layer** --- Separate security groups for Web,
    Application, and Database tiers

This project was created as a practical learning project to understand
AWS networking, Terraform modules, security groups, private/public
subnets, NAT Gateway routing, EC2, and RDS.

------------------------------------------------------------------------

## Architecture

``` mermaid
flowchart TB
    Internet((Internet))
    IGW[Internet Gateway]
    NAT[NAT Gateway]

    subgraph VPC["AWS VPC 10.0.0.0/16"]

        subgraph WEB["Public Web Subnet<br/>10.0.0.0/24"]
            WebSG["Web Security Group<br/>SSH from configured IP<br/>HTTP 80 / HTTPS 443"]
            WebEC2["Web EC2<br/>Public IP"]
            WebSG --> WebEC2
        end

        subgraph APP["Private App Subnet<br/>10.0.1.0/24"]
            AppSG["App Security Group<br/>TCP 8080 from Web SG"]
            AppEC2["App EC2<br/>No Public IP"]
            AppSG --> AppEC2
        end

        subgraph DB["Private DB Subnets<br/>10.0.2.0/24<br/>10.0.3.0/24"]
            DBSG["DB Security Group<br/>MySQL 3306 from App SG"]
            RDS["Amazon RDS MySQL<br/>10 GB Encrypted Storage"]
            DBSG --> RDS
        end
    end

    Internet --> IGW
    IGW --> WebEC2
    WebEC2 -->|TCP 8080| AppEC2
    AppEC2 -->|TCP 3306| RDS
    AppEC2 -->|Outbound Internet| NAT
    NAT --> IGW
```

### Traffic Flow

1.  Internet traffic reaches the Web tier through the Internet Gateway.
2.  The Web EC2 instance is deployed in a public subnet and has a public
    IP.
3.  Application traffic is allowed from the Web security group to the
    App security group on TCP port `8080`.
4.  The App EC2 instance is deployed in a private subnet and does not
    have a public IP.
5.  Database traffic is allowed from the App security group to the DB
    security group on TCP port `3306`.
6.  RDS MySQL is deployed privately using two database subnets.
7.  The App subnet uses the NAT Gateway for outbound internet access
    without exposing the App EC2 instance directly to the internet.

------------------------------------------------------------------------

## AWS Resources

This project provisions the following major AWS resources:

-   VPC with CIDR `10.0.0.0/16`
-   Internet Gateway
-   4 subnets across multiple Availability Zones
    -   1 public Web subnet
    -   1 private App subnet
    -   2 private DB subnets
-   Public route table
-   Private App route table
-   Private DB route table
-   NAT Gateway
-   Elastic IP for NAT Gateway
-   Web EC2 instance
-   App EC2 instance
-   Web security group
-   App security group
-   DB security group
-   RDS subnet group
-   RDS MySQL database
-   EC2 key pair

------------------------------------------------------------------------

## Security Design

The project uses separate security groups for each tier.

### Web Security Group

  Traffic   Source                   Port
  --------- ---------------------- ------
  SSH       Configured public IP       22
  HTTP      Internet                   80
  HTTPS     Internet                  443

SSH access is restricted through the `ssh_cidr` Terraform variable
rather than allowing SSH from the entire internet.

### Application Security Group

  Traffic               Source                 Port
  --------------------- -------------------- ------
  Application traffic   Web Security Group     8080

The App EC2 instance does not have a public IP.

### Database Security Group

  Traffic   Source                 Port
  --------- -------------------- ------
  MySQL     App Security Group     3306

The RDS database is not publicly accessible.

------------------------------------------------------------------------

## Terraform Module Structure

The infrastructure is divided into separate modules to keep the
configuration organized and reusable.

``` text
Three-Tier-Architecture/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── .gitignore
├── .terraform.lock.hcl
├── README.md
│
├── vpc-module/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── web-module/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── app-module/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── db-module/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── screenshots/
    ├── 01-vpc-resource-map.png
    ├── 02-vpc-subnets.png
    ├── 03-route-tables.png
    ├── 04-nat-gateway.png
    ├── 05-web-ec2.png
    ├── 06-app-ec2.png
    ├── 07-web-security-group.png
    ├── 08-app-security-group.png
    ├── 09-db-security-group.png
    ├── 10-rds-configuration.png
    ├── 11-terraform-output.png
    └── 12-terraform-plan.png
```

------------------------------------------------------------------------

## Prerequisites

Before using this project, make sure you have:

-   An AWS account
-   Terraform installed
-   AWS credentials configured securely
-   An AWS EC2 key pair public key available locally
-   Permission to create the required AWS resources

The Terraform configuration expects the public key at:

``` text
~/.ssh/mytf_key_pair.pub
```

If you use a different public key path, update the `aws_key_pair`
resource in the root `main.tf`.

------------------------------------------------------------------------

## Configuration

Create your local Terraform variables file from the example:

``` bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the file:

``` bash
nano terraform.tfvars
```

Example structure:

``` hcl
region_name   = "us-east-1"
ami_id        = "YOUR_AMI_ID"
instance_type = "t3.micro"

db_username = "YOUR_DB_USERNAME"
db_password = "YOUR_DB_PASSWORD"

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
  "us-east-1d"
]

ssh_cidr = "YOUR_PUBLIC_IP/32"
```

### Important

`terraform.tfvars` contains environment-specific values and database
credentials.

**Do not commit `terraform.tfvars` to GitHub.**

The repository includes `terraform.tfvars.example` so that users can
create their own local configuration.

------------------------------------------------------------------------

## Terraform Workflow

### 1. Initialize Terraform

``` bash
terraform init
```

### 2. Format the configuration

``` bash
terraform fmt -recursive
```

### 3. Validate the configuration

``` bash
terraform validate
```

Expected result:

``` text
Success! The configuration is valid.
```

### 4. Review the execution plan

``` bash
terraform plan
```

Review the resources carefully before applying.

### 5. Create the infrastructure

``` bash
terraform apply
```

Confirm the operation when Terraform asks for approval.

### 6. View Terraform outputs

``` bash
terraform output
```

The project exposes:

-   VPC ID
-   Web EC2 instance ID
-   App EC2 instance ID
-   RDS endpoint

### 7. Destroy the infrastructure

When the project is no longer required:

``` bash
terraform destroy
```

Confirm the destruction when prompted.

------------------------------------------------------------------------

## Terraform Outputs

The root module provides the following outputs:

``` text
vpc_id
web_instance_id
app_instance_id
rds_endpoint
```

The RDS endpoint can also be displayed with:

``` bash
terraform output -raw rds_endpoint
```

------------------------------------------------------------------------

## Cost Considerations

AWS resources can generate charges while they are running.

In particular, pay attention to:

-   EC2 instances
-   Amazon RDS
-   NAT Gateway
-   Elastic IP usage
-   Storage and data transfer

This project is intended for hands-on learning. After testing the
infrastructure, destroy resources that are no longer needed:

``` bash
terraform destroy
```

Check the current AWS pricing for your selected region before deploying
resources.

------------------------------------------------------------------------

## Security and GitHub Safety

The following files should **not** be committed:

``` text
terraform.tfvars
*.tfstate
*.tfstate.*
*.tfplan
.terraform/
*.pem
*.key
```

The repository's `.gitignore` is configured to exclude these files.

The Terraform dependency lock file should be committed:

``` text
.terraform.lock.hcl
```

### Important State File Note

Terraform state can contain sensitive infrastructure information and may
contain sensitive values.

Never upload Terraform state files to a public GitHub repository.

------------------------------------------------------------------------

## Project Screenshots

The following screenshots document the AWS resources and Terraform
execution.

### 1. VPC Resource Map

![VPC Resource Map](screenshots/01-vpc-resource-map.png)

### 2. VPC Subnets

![VPC Subnets](screenshots/02-vpc-subnets.png)

### 3. Route Tables

![Route Tables](screenshots/03-route-tables.png)

### 4. NAT Gateway

![NAT Gateway](screenshots/04-nat-gateway.png)

### 5. Web EC2 Instance

![Web EC2 Instance](screenshots/05-web-ec2.png)

### 6. App EC2 Instance

![App EC2 Instance](screenshots/06-app-ec2.png)

### 7. Web Security Group

![Web Security Group](screenshots/07-web-security-group.png)

### 8. App Security Group

![App Security Group](screenshots/08-app-security-group.png)

### 9. Database Security Group

![Database Security Group](screenshots/09-db-security-group.png)

### 10. RDS Configuration

![RDS Configuration](screenshots/10-rds-configuration.png)

### 11. Terraform Output

![Terraform Output](screenshots/11-terraform-output.png)

### 12. Terraform Plan

![Terraform Plan](screenshots/12-terraform-plan.png)

------------------------------------------------------------------------

## What I Practiced

This project helped me practice:

-   Terraform configuration and workflow
-   Terraform modules
-   Variables and outputs
-   AWS provider configuration
-   VPC design
-   Public and private subnets
-   Route tables and route associations
-   Internet Gateway
-   NAT Gateway
-   Elastic IP
-   EC2 provisioning
-   Security group design
-   Security group-to-security group access
-   Amazon RDS MySQL
-   RDS subnet groups
-   Private database networking
-   Terraform validation and planning
-   Infrastructure cleanup with `terraform destroy`
-   Basic infrastructure security practices

------------------------------------------------------------------------

## Important Project Scope

This project focuses on **infrastructure provisioning and networking**.

Terraform provisions the EC2 instances, but it does not automatically
install or deploy an application on the Web or App instances. The
security groups and network paths are configured so that an application
can be deployed on top of the infrastructure.

------------------------------------------------------------------------

## Learning Outcome

The main goal of this project was to understand how a basic AWS
three-tier architecture can be represented as Infrastructure as Code
using Terraform and organized into reusable modules.

The project demonstrates the separation of:

``` text
Web Tier
   ↓
Application Tier
   ↓
Database Tier
```

while keeping the application and database tiers private from direct
internet access.

------------------------------------------------------------------------

## License

This project is intended for learning and portfolio purposes.

