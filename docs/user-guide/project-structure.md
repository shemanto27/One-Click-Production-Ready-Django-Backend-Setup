# Project Structure

One Click DRF generates a clean, modular structure where the Django backend is isolated in its own directory, and infrastructure/deployment files are organized at the root.

## Directory Layout

```
project-root/
├── backend/              # Django backend source code
│   ├── core/             # Project configuration (settings.py, urls.py, etc.)
│   ├── apps/             # Your Django apps live here
│   ├── manage.py         # Django management CLI
│   ├── .env              # Environment variables
│   ├── .gitignore        # Backend-specific ignore rules
│   ├── Dockerfile        # Backend container definition
│   ├── erd.sh            # ERD generation utility
│   └── requirements/     # Dependencies split (base, dev, prod)
├── nginx/                # Nginx proxy configuration
├── .github/              # CI/CD (GitHub Actions workflows)
├── infra/                # Infrastructure as Code (Terraform & Ansible)
├── monitoring/           # Observability (Prometheus/Grafana)
├── docker-compose.yml    # Root orchestration for all services
└── DEVELOPMENT_GUIDE.md  # Detailed guide to get started
```

## Backend Structure

The `backend/` directory contains your Django application:

### Core Module

- `settings.py` - Django settings (split for dev/prod)
- `urls.py` - URL routing
- `wsgi.py` / `asgi.py` - WSGI/ASGI application

### Apps Directory

All Django apps are organized under `apps/`:

```
apps/
├── users/
│   ├── models.py
│   ├── views.py
│   ├── serializers.py
│   ├── urls.py
│   └── admin.py
└── orders/
    └── ...
```

## Infrastructure

### Docker

- `backend/Dockerfile` - Multi-stage build for Django
- `docker-compose.dev.yml` - Development environment
- `docker-compose.prod.yml` - Production environment

### CI/CD

- `.github/workflows/pipeline.yml` - Automated testing and deployment

### Infrastructure as Code

- `infra/terraform/` - AWS infrastructure templates
- `infra/ansible/` - Server configuration playbooks

### Monitoring

- `monitoring/prometheus.yml` - Metrics collection configuration

## Extensibility

This structure is designed for scaling:

- **Full-Stack**: Add a `frontend/` folder for React, Next.js, Vue, etc.
- **Microservices**: Add `ml-service/` or `ai-apps/` folders
- **Orchestration**: Integrate new services into root `docker-compose.yml`

The architecture ensures your entire ecosystem remains easy to deploy in the cloud.
