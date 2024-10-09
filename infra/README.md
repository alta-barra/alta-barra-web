# Infrastructure Management

This repository contains the Tofu configuration for managing infrastructure across different environments (e.g., `production`, `staging`). All Tofu operations (apply, destroy) should be done using the provided scripts to ensure consistency and prevent issues with state management.

## Directory Structure

```plaintext
/infra
│
├── /environments
│   ├── /production          # Production environment configurations
│   ├── /production/main.tf
│   ├── /production/backend.tf
│   ├── /production/outputs.tf
│   ├── /production/variables.tf
│   ├── /production/opentofu.tfvars
│   │
│   └── /staging             # Staging environment configurations
│
├── /modules                 # Reusable Tofu modules (e.g., networking, compute, rds)
│
├── /global                  # Global resources shared across environments (e.g., IAM, S3)
│
└── /scripts                 # Automation scripts for Tofu operations
```
