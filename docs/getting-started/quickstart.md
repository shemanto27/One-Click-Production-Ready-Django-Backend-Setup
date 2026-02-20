# Quick Start

This guide will help you create your first production-ready Django REST Framework project in minutes.

## Create a New Project

Initialize a new project with all features:

```bash
ocd init myproject --all
```

This will:

1. Prompt you for project details
2. Generate a complete project structure
3. Install all dependencies
4. Set up Docker, CI/CD, and infrastructure
5. Run migrations and create a superuser

## Project Prompts

You'll be asked for:

- **Project Name**: Name of your Django project (default: directory name)
- **App Names**: Django apps to create (default: `users`)
- **GitHub URL**: Optional repository URL for auto-push

## Run the Project

### Using Docker (Recommended)

```bash
cd myproject
docker compose -f docker-compose.dev.yml up --build
```

### Running Locally

```bash
cd myproject/backend
source .venv/bin/activate
python manage.py runserver
```

## Access Your Application

- **API**: http://localhost:8000
- **Admin Panel**: http://localhost:8000/admin
- **Swagger Docs**: http://localhost:8000/swagger

### Default Credentials

- **Email**: admin@gmail.com
- **Password**: admin123

!!! warning
    Change these credentials in production!

## Project Structure

```
myproject/
├── backend/              # Django application
│   ├── core/            # Project settings
│   ├── apps/            # Your Django apps
│   └── manage.py
├── nginx/               # Nginx configuration
├── .github/workflows/   # CI/CD pipelines
├── infra/              # Terraform & Ansible
└── monitoring/         # Prometheus/Grafana
```

## Next Steps

- [CLI Commands Reference](../user-guide/cli-commands.md)
- [Project Structure Details](../user-guide/project-structure.md)
- [Configuration Guide](../user-guide/configuration.md)
