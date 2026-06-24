# aws-azure-both-example

Deploys a simple Linux VM on **both Azure and AWS** using a single reusable Terraform workflow.

## Architecture

```
.github/workflows/
├── azure-vm-dev.yml       # Azure VM → dev
├── azure-vm-prod.yml      # Azure VM → prod
├── aws-ec2-dev.yml        # AWS EC2 → dev
└── aws-ec2-prod.yml       # AWS EC2 → prod

infra/
├── azure-vm/              # Azure Linux VM (Ubuntu 22.04)
│   ├── provider.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── environments/
│       ├── dev.tfvars
│       └── prod.tfvars
└── aws-ec2/               # AWS EC2 (Amazon Linux 2023)
    ├── provider.tf
    ├── variables.tf
    ├── locals.tf
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    └── environments/
        ├── dev.tfvars
        └── prod.tfvars
```

## How it works

- Both clouds use the **same reusable Terraform workflow** from `PixelTech-Solutions/Terraform`
- State is stored in **Azure Storage** (single backend for both)
- State path: `incident-commander/<service>/<environment>/terraform.tfstate`
- **Apply** and **Destroy** require manual approval via GitHub Environments

## Required secrets (repo → Settings → Secrets)

| Secret | For |
|---|---|
| `ARM_CLIENT_ID` | Azure Service Principal |
| `ARM_TENANT_ID` | Azure tenant |
| `ARM_SUBSCRIPTION_ID` | Azure subscription |
| `ARM_CLIENT_SECRET` | Azure SP password (or use OIDC) |
| `AWS_ACCESS_KEY_ID` | AWS IAM user |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret |
| `AWS_REGION` | e.g. `us-east-1` |
| `TF_VAR_ADMIN_SSH_PUBLIC_KEY` | SSH public key for Azure VM |

## Required GitHub Environments

Create in Settings → Environments with **Required reviewers**:

- `dev` / `dev-destroy`
- `prod` / `prod-destroy`
