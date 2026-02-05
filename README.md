# One-Click Production-Ready Django Backend Setup

![Python](https://img.shields.io/badge/python-3.12+-blue.svg)
![Django](https://img.shields.io/badge/Django-6.0+-green.svg)
![DRF](https://img.shields.io/badge/DRF-3.16+-red.svg)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-%23EE0000.svg?style=flat&logo=ansible&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat&logo=amazon-aws&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgres-%23316192.svg?style=flat&logo=postgresql&logoColor=white)
![Sentry](https://img.shields.io/badge/Sentry-362D59?style=flat&logo=sentry&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=flat&logo=githubactions&logoColor=white)
![isort](https://img.shields.io/badge/%20imports-isort-%231674b1?style=flat&labelColor=ef8336)
![Code style](https://img.shields.io/badge/code%20style-black-000000.svg)
![Maintained](https://img.shields.io/badge/Maintained-yes-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

[![Stars](https://img.shields.io/github/stars/shemanto27/One-Click-Production-Ready-Django-Backend-Setup?style=social)](https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup/stargazers)
[![Forks](https://img.shields.io/github/forks/shemanto27/One-Click-Production-Ready-Django-Backend-Setup?style=social)](https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup/network/members)
[![Issues](https://img.shields.io/github/issues/shemanto27/One-Click-Production-Ready-Django-Backend-Setup)](https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup/issues)

A powerful bash script for a one-click **Production-ready Django REST Framework** setup. This setup is designed for modern DevOps workflows, including containerization, infrastructure as code, and automated deployment.

## 🚀 Features & Setup

This script automates the creation and configuration of:
- **Django Core**: Latest Django with `uv` package manager.
- **API Versioning**: Industry-standard `/v1/` routing.
- **Docker Ready**: `Dockerfile`, `docker-compose.dev.yml`, and `docker-compose.prod.yml`.
- **CI/CD Pipeline**: GitHub Actions template for Docker Hub and EC2 deployment.
- **Infrastructure as Code (IaC)**:
    - **Terraform**: Provision AWS EC2, S3, RDS (Postgres), and Security Groups.
    - **Ansible**: Automated server provisioning, Nginx setup, and SSL (Certbot).
- **Security & Production**: 
    - `python-decouple` for environment variables.
    - `Whitenoise` for static files.
    - `Gunicorn` server.
- **Error Tracking**: Pre-configured Sentry integration.
- **Authentication**: JWT Auth and Social Auth (Google) ready.
- **Automation & Quality**: Pre-configured `pre-commit` hooks, `Black` formatter, and `Isort`.
- **ERD Generation**: Automated Entity Relationship Diagram creation script (`erd.sh`).
- **GitHub Integration**: Automatic repo initialization and first push.

---

## 🛠️ Quick Start

1. **Download the script**:
   Place `init.sh` in your project root.

2. **Give execution permission**:
   ```bash
   chmod +x init.sh
   ```

3. **Run the script**:
   ```bash
   ./init.sh
   ```

---

## ⚙️ Customization (Ctrl + F)

After running the script, you can easily find and change specific settings by searching for the following keywords or categories:

- **APP NAMES**: During run, you'll be prompted for app names (e.g., `users admin`).
- **SHEMANTO**: Search for this to find author credits and links.
- **DOCKER HUB**: Look in `.github/workflows/pipeline.yml` to change the `DOCKER_REPO`.
- **CODE STYLE**: Configuration is in `pyproject.toml` and `.pre-commit-config.yaml`.
- **AWS CONFIG**: Look in `infra/terraform/` to adjust regions, instance types, and bucket names.
- **DOMAIN/SSL**: Look in `infra/ansible/playbook.yml` to change `website_domain` and `certbot_email`.
- **DATABASE**: Search for `DATABASE_URL` in `.env`.
- **SUPERUSER**: Default is `admin@gmail.com` with `admin123`.

---

## 📦 Requirements

- Linux OS (Ubuntu recommended)
- `curl` (to install `uv`)
- `git`

---
*Created by [Shemanto Sharkar](https://github.com/shemanto27)*
