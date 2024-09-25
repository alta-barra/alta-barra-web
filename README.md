# Alta-Barra Company Website

[![Deploy Production Environment](https://github.com/alta-barra/alta-barra-web/actions/workflows/production-deploy.yml/badge.svg)](https://github.com/alta-barra/alta-barra-web/actions/workflows/production-deploy.yml)

This repository contains the main website for Alta-Barra, built with Elixir and Phoenix, and deployed to AWS.

## Prerequisites

- Elixir and Phoenix framework
- Podman or Docker
- AWS CLI configured with appropriate permissions

## Local Development

To start the server locally:

1. Set up the database:
   ```bash
   ./scripts/local_dev_setup.sh
   ```

2. Install and setup dependencies:
   ```bash
   mix setup
   ```

3. Start the Phoenix server:
   ```bash
   mix phx.server
   ```
   Or inside IEx:
   ```bash
   iex -S mix phx.server
   ```

## Useful Commands

- Run tests:
  ```bash
  mix test
  ```

- Format code:
  ```bash
  mix format
  ```

- Check for compiler warnings:
  ```bash
  mix compile --warnings-as-errors
  ```

- Generate a new migration:
  ```bash
  mix ecto.gen.migration migration_name
  ```

## Deployment

To deploy the application:

1. Navigate to the scripts directory:
   ```bash
   cd scripts
   ```

2. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

Note: Always use the provided scripts for deployment and Terraform operations. Do not run Terraform commands directly.

## Infrastructure Management

All infrastructure is managed using [OpenTofu](https://opentofu.org/) Terraform To make changes:

1. Navigate to the scripts directory:
   ```bash
   cd scripts
   ```

2. Use the appropriate script for your needs:
   - To apply changes: `./deploy.sh`
   - To destroy resources: `./destroy.sh`

## License

This project is proprietary software owned by Alta-Barra. All rights reserved.
