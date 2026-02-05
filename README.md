# One-Click Production-Ready Django Backend Setup

![Python](https://img.shields.io/badge/python-3.12+-blue.svg)
![Django](https://img.shields.io/badge/Django-6.0+-green.svg)
![DRF](https://img.shields.io/badge/DRF-3.16+-red.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Maintained](https://img.shields.io/badge/Maintained-yes-green.svg)
![Code style](https://img.shields.io/badge/code%20style-black-000000.svg)
![isort](https://img.shields.io/badge/%20imports-isort-%231674b1?style=flat&labelColor=ef8336)

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
