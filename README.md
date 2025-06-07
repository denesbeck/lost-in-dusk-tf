# lost-in-dusk-tf

Terraform configurations for deploying the `lost-in-dusk` portfolio infrastructure on AWS, managed remotely through [HCP Terraform](https://www.hashicorp.com/cloud/terraform).

---

## 📋 Overview

This project provisions and manages infrastructure for the [`lost-in-dusk`](https://github.com/denesbeck/lost-in-dusk) personal portfolio site.

Infrastructure is deployed to **AWS**.

---

## 🏗️ Architecture Components

| Service                   | Purpose                               |
| ------------------------- | ------------------------------------- |
| **S3**                    | Hosts static frontend assets          |
| **CloudFront**            | CDN for low-latency global delivery   |
| **Route 53**              | DNS routing for domain                |
| **ACM**                   | SSL/TLS certificate management        |
| **API Gateway + Lambda**  | API endpoint handling                 |
| **Terraform Cloud (HCP)** | Remote backend for state and workflow |

---

## 🔧 Prerequisites

- **Terraform CLI**: Installed on your local machine ([download](https://www.terraform.io/downloads))
- **HCP Terraform Account**: Set up with an associated workspace for this repo
- **AWS Account & IAM Permissions**
- **Terraform CLI Authentication to HCP**: via `terraform login`

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/denesbeck/lost-in-dusk-tf.git
cd lost-in-dusk-tf
```

### 2. Log in to HCP Terraform

```bash
terraform login
```

This authenticates your CLI with Terraform Cloud for remote state and run operations.

### 3. Initialize the Workspace

```bash
terraform init
```

This will automatically detect and configure the remote backend specified in `providers.tf`.

### 4. Plan & Apply (via CLI or HCP UI)

You can preview changes locally with:

```bash
terraform plan
```

You can apply changes by pushing them to the default branch (usually `main`) to trigger a run via VCS integration.

---

## 📂 Repository Structure

- `s3.tf` – S3 bucket definition for frontend hosting
- `api-gw.tf` - API Gateway configuration
- `cloudfront.tf` – CDN configuration
- `route53.tf` – DNS management
- `acm.tf` – Certificate provisioning
- `iam.tf` - IAM roles for resources
- `providers.tf` – AWS and Terraform Cloud provider setup
- `variables.tf` – Input variables for modularity

---

## ☁️ Terraform Cloud Backend

This project uses the following remote backend configuration (found in `providers.tf`):

```hcl
terraform {
  cloud {
    organization = "crimson-org"

    workspaces {
      name = "lost-in-dusk"
    }
  }
}
```

---

## 📌 Notes

- Terraform state is stored and versioned in HCP Terraform.
- You can manage plans, runs, and approvals through the [Terraform Cloud UI](https://app.terraform.io).
- SSL certificates must be created in `us-east-1` for use with CloudFront.
