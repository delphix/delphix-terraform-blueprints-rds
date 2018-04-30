# delphix-terraform-blueprints-rds

Terraform blueprints that deploy RDS and Delphix assets into AWS and configures them to work together.

#### Table of Contents
1.  [Description](#description)
2.  [Prerequisites](#prereqs)
3.  [Installation](#installation)
4.  [Usage](#usage)
5.  [Links](#links)
6.  [Reporting Issues](#reporting-issues)
7.  [License](#license)

## <a id="description"></a>Description

The purpose of this project is to demonstrate how Delphix can ingest and leverage data from Amazon RDS. This repository contains Terraform blueprints that will create all of the objects and data needed to complete the demonstration.

## <a id="prereqs"></a>Prerequisites

These instructions assume the reader has a basic knowledge of Terraform and a working understanding of AWS.
Pre-requisites:
1. Access to Delphix 5.2.4 AMI in AWS obtained [from here](https://www.terraform.io/downloads.html) (requires licensed account)
2. Access to the CentOS6.9 Oracle 11.2.0.4 AMI in AWS created [from here](https://github.com/delphix/packer-delphix-centos69-oracle11204)
3. Appropriate permissions to create, manage, and destroy the corresponding assets in AWS.
  * VPC
  * Subnet
  * Route
  * Internet Gateway
  * Security Group
  * AMI (Read Access)
  * EC Instance
  * DMS Replication Instance
  * DMS Replication Subnet
  * DMS Replication Task
  * DMS Endpoint
  * RDS Database Instance
  * RDS Database Subnet Group
4. An AWS Key Pair for the region you will deploy into (us-west-2, by default)

## <a id="installation"></a>Installation

* Clone this repository
* Install Terraform 11.7 or above [from here](https://www.terraform.io/downloads.html) to  /usr/local/bin/terraform
* Install the terraform-provider-delphix [from here](https://github.com/delphix/terraform-provider-delphix) into the phase_2 subdirectory of the cloned repo

```bash
git clone https://github.com/delphix/delphix-terraform-blueprints-rds
cd delphix-terraform-blueprints-rds
```

## <a id="usage"></a>Usage

###Building

1. Edit the .example.env file in the root directory of the cloned repo
  The following variables should be set before proceeding, you can proceed with the defaults on the remaining:
  * TF_VAR_access_key - Your AWS Access Key
  * TF_VAR_secret_key - Your AWS Secret Key
  * TF_VAR_key_name - The name of your AWS key pair (default us-west-2 region)
  * TF_VAR_rds_db_password - 8-30 character password of your choosing
  * TF_VAR_delphixdb_password - 8-30 character password of your choosing
  * TF_VAR_delphix_admin_password - password of your choosing
2. source the .example.env file, i.e. ```source .example.env```
3. change to the phase_1 subdirectory in your terminal
5. Run ```terraform init``` to initialize Terraform in the directory
6. Run ```terraform apply``` to apply the Terraform plan to build out the assets for Phase 1.
7. After the assets are built, navigate to the Delphix public IP in a web browser (it will take several minutes to become available)
8. After the Delphix setup wizard begins, complete the setup with your information and default values. Be sure to jot down passwords.
  * If you need detail on completing the setup wizard, look at [these resources](./docs/setup_wizard)
9. change to the root directory of the cloned repo
10. ssh into the Delphix engine as delphix_admin, obtain the systemKey (details in them comments of the .example.env file)
11. Edit the .example.env file to set the TF_VAR_delphix_engine_system_key
12. source the .example.env file, i.e. ```source .example.env```
13. change to the phase_2 subdirectory in your terminal
10. Copy the private key (.pem) from your key pair into the phase_2 folder. 
13. Run ```terraform init``` to initialize Terraform in the directory
14. Run ```terraform apply``` to apply the Terraform plan to build out the assets for Phase 2. This process will take 15-20 minutes to complete.
15. After the assets are built, you will need to start the dms replication task. Select the DMS replication task in your AWS console and push start.
16. Once the initial load is complete, the data has been replicated from AWS into the Delphix Engine.

###Destroying

1. Stop the DMS replication task in the AWS console
2. In your terminal, navigate to the root project directory.
3. source the .example.env file, i.e. ```source .example.env```
4. change to the phase_2 subdirectory
5. Run ```terraform destroy``` to destroy the phase_2 assets. This process will take ~15 minutes to complete.
6. Once complete, change to the phase_1 subdirectory of the cloned repo
7. Run ```terraform destroy``` to destroy the phase_1 assets.

## <a id="links"></a>Links

*   [Delphix Downloads Page](https://download.delphix.com/)
*   [AWS Getting Started Tutorial](https://aws.amazon.com/getting-started/tutorials/)
*   [terraform-provider-delphix](https://github.com/delphix/terraform-provider-delphix)
*   [screenshots of the setup wizard](./docs/setup_wizard)
*   [video of phase_1 init+apply](https://vimeo.com/267154293/124a0871ca)
*   [video of phase_2 init+apply](https://vimeo.com/267153750/475e16463b)
*   [video of phase_1 destroy](https://vimeo.com/267152770/33b218aafe)
*   [video of phase_2 destroy](https://vimeo.com/267152866/29b5a02739)


#### Workflow

1.  Fork the project.
2.  Make your bug fix or new feature.
3.  Add tests for your code.
4.  Send a pull request.

Contributions must be signed as `User Name <user@email.com>`. Make sure to [set up Git with user name and email address](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup). Bug fixes should branch from the current stable branch. New feature should be based on the `master` branch.

## <a id="reporting_issues"></a>Reporting Issues

Issues should be reported in the repo's issue tab.

## <a id="license"></a>License

This is code is licensed under the Apache License 2.0. Full license is available [here](./LICENSE).
