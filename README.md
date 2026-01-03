# Task 7: Terraform Remote State & Jenkins Concurrency

## Objective

Implement **Terraform remote state management** and **Jenkins concurrency controls** to ensure safe, team-ready infrastructure deployments. This task prevents Terraform state corruption and avoids concurrent deployments to the same environment.

---

## Tools & Technologies Used

* **Terraform** – Infrastructure as Code
* **AWS S3** – Remote backend for Terraform state
* **AWS DynamoDB** – State locking mechanism
* **Jenkins** – CI/CD pipeline
* **GitHub** – Source code management

---

## Prerequisites

* AWS account with permissions for **S3**, **DynamoDB**, and **EC2**
* Jenkins installed and running
* Terraform installed
* AWS CLI configured

---

## Project Structure

```
terraform-task7/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf
├── envs/
│   ├── dev/backend.tf
│   ├── uat/backend.tf
│   └── prod/backend.tf
├── Jenkinsfile
└── README.md
```

---

## AWS Credential Configuration

AWS credentials are configured using **AWS CLI** and are **not hardcoded** in Terraform.

```bash
aws configure
```

Credentials are securely stored in:

```
~/.aws/credentials
```

---

## Terraform Remote Backend Configuration

### S3 Bucket

* Stores Terraform state files
* Versioning enabled
* Encryption enabled

Example bucket name:

```
terraform-remote-state-manoj
```

### DynamoDB Table

* Used for Terraform state locking

Configuration:

```
Table Name : terraform-locks
Partition Key : LockID (String)
```

---

## Environment-wise Backend Configuration

Each environment has a **separate Terraform state file**.

### Dev Backend

```hcl
bucket         = "terraform-remote-state-manoj"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
```

### UAT Backend

```hcl
bucket         = "terraform-remote-state-manoj"
key            = "uat/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
```

### Prod Backend

```hcl
bucket         = "terraform-remote-state-manoj"
key            = "prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
```

---

## Terraform Execution Steps

Initialize Terraform with backend:

```bash
terraform init -backend-config=../envs/dev/backend.tf -reconfigure
```

Plan the infrastructure:

```bash
terraform plan -var="environment=dev"
```

Apply the infrastructure:

```bash
terraform apply -auto-approve -var="environment=dev"
```

---

## Jenkins Pipeline Configuration

### Key Features

* Prevents concurrent deployment to the **same environment**
* Allows parallel deployment to **different environments**
* Ensures Terraform runs in correct order: `init → plan → apply`

### Jenkinsfile Highlights

* Uses `lock("terraform-${ENV}")` to control concurrency
* Uses parameters to select environment (dev, uat, prod)
* Uses remote backend for Terraform state

---

## Concurrency Control Logic

| Scenario             | Behavior           |
| -------------------- | ------------------ |
| Two builds for DEV   | Second build waits |
| DEV + UAT builds     | Runs in parallel   |
| State already locked | Pipeline fails     |

---

## Proof of Implementation

* Terraform state files stored in **S3**, not locally
* Lock entries created in **DynamoDB** during apply
* Jenkins logs show lock acquisition and waiting behavior
* Separate state files for DEV, UAT, and PROD

---

## Cleanup (Destroy Infrastructure)

```bash
terraform destroy -auto-approve -var="environment=dev"
terraform destroy -auto-approve -var="environment=uat"
terraform destroy -auto-approve -var="environment=prod"
```

---

