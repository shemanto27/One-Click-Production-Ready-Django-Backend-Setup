<a name="top"></a>
![heading image](https://raw.githubusercontent.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup/main/banner.gif)

# One Click DRF (OCD) 🚀

> **বাংলায় README ফাইলটি পড়ে দেখুন [এখানে (README.bn.md)](./README.bn.md)**

**One Click DRF** is a powerful CLI tool designed to bootstrap **production-ready** Django REST Framework projects in seconds.

[![PyPI version](https://img.shields.io/pypi/v/one-click-drf)](https://pypi.org/project/one-click-drf/)
[![License](https://img.shields.io/github/license/shemanto27/One-Click-Production-Ready-Django-Backend-Setup)](https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/shemanto27/One-Click-Production-Ready-Django-Backend-Setup?style=social)](https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup)
[![PyPI Downloads](https://static.pepy.tech/personalized-badge/one-click-drf?period=total&units=INTERNATIONAL_SYSTEM&left_color=GREY&right_color=GREEN&left_text=downloads)](https://pepy.tech/projects/one-click-drf)
### 🛠️ Technology Stack
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)](https://python.org)
[![Django](https://img.shields.io/badge/Django-092E20?logo=django&logoColor=white)](https://djangoproject.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://docker.com)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&logoColor=white)](https://ansible.com)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Nginx](https://img.shields.io/badge/Nginx-009639?logo=nginx&logoColor=white)](https://nginx.org)

### Coming Soon
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)](https://grafana.com)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=azure&logoColor=white)](https://azure.com)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?logo=google-cloud&logoColor=white)](https://cloud.google.com)


⭐ **Star us on GitHub** — your support motivates us a lot! 🙏😊

[![Follow Shemanto Sharkar](https://img.shields.io/badge/Follow-LinkedIn-0A66C2?logo=linkedin)](https://www.linkedin.com/in/shemanto/)
[![Share on LinkedIn](https://img.shields.io/badge/share-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/sharing/share-offsite/?url=https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup)

---

Stop copy-pasting code from old projects. Start with a solid foundation.

## 🌟 The Story Behind One Click DRF
Every time a new project starts at the office, I see a familiar cycle: developers need to start everything from scratch, from ground zero, through repetitive and manual work like this:
- **Repetitive Installations:** Manually installing `djangorestframework`, `django-cors-headers`, `drf-yasg(Swagger)`, and other essential packages every single time.
- **Settings Fatigue:** Manually tweaking settings, creating `.env` files, and mapping them to variables.
- **The Hunt:** Going to GitHub just to find a standard Python `.gitignore`.
- **Human Error:** Forgetting something critical—like CORS settings—only to realize it hours later when the frontend developer can't connect.
- **Confidence Gap:** Even after hours of setup, no one is 100% sure if the environment is truly "perfect" or "production-ready."

**One Click DRF** was born to solve this. It automates these repetitive tasks and guarantees a battle-tested, production-ready foundation in **seconds**. No more copy-pasting, no more forgotten settings—just one command to start building what actually matters.

## 🚀 What you get with `ocd`
When you initialize a project with `ocd`, you’re not just getting a folder—you’re getting a full production environment:
- **🐳 Docker Ready:** Multi-stage `Dockerfile` and `docker-compose.yml` for development and production.
- **⚙️ CI/CD (GitHub Actions):** Pre-configured workflows for automated testing, linting, and deployment.
- **🏗️ Infrastructure as Code (IaC):** Terraform templates to manage your cloud resource effortlessly.
- **☁️ AWS Deployment Ready:** Built-in configurations to deploy your backend to AWS with confidence.
- **📊 Monitoring & Observability:** Integrated Prometheus and Grafana setup to keep an eye on your app's health.
- **🛠️ Production Settings & .env:** Professionally split `settings.py` and automatically generated `.env` file.
- **📝 Swagger API Ready:** Instant API documentation with `drf-yasg` so you're ready to test immediately.
- **📂 Organized Apps Folder:** A clean architecture where all your Django apps live in a dedicated `apps/` directory.
- **🔒 Standard .gitignore:** A pre-configured, standard Python `.gitignore` so you don't have to find one.
- **🚀 GitHub Integration:** Option to automatically initialize a git repo and push to a new GitHub repository in one go.

## 📦 Installation

Since **one-click-drf** is a CLI tool, it is recommended to install it globally using `uv`:

```bash
uv tool install one-click-drf
```

If your system doesn't have `uv` yet, follow the [installation guide here](https://docs.astral.sh/uv/getting-started/installation/).

Alternatively, you can use pip:
```bash
pip install one-click-drf
```

## 🚀 Usage

### Initialize a new project

```bash
ocd init myproject
```
This creates a new folder `myproject` with a production-ready structure.

### Initialize in current directory

```bash
ocd init .
```

### Enable Optional Features

You can mix and match flags:

```bash
ocd init myproject --docker --ci-cd
```

Or enable everything:

```bash
ocd init myproject --all
```

### Check Version

```bash
ocd version
# or
ocd --version
```

## 🚩 CLI Flags

| Flag | Description |
|------|-------------|
| `--docker` | Adds `Dockerfile` and `docker-compose.yml` |
| `--ci-cd` | Adds GitHub Actions workflow for testing & linting |
| `--iac` | Adds Terraform skeleton for AWS |
| `--observability` | Adds Prometheus configuration |
| `--all` | Enables all above features |

## 📂 Project Structure

We follow a clean, modular structure where the Django backend is isolated in its own directory, and infrastructure/deployment files are organized at the root:

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

### 🚀 Built for the Future (Extensibility)
This structure is intentionally designed for scaling into a full-stack or microservices architecture:
- **Full-Stack Ready**: Need a frontend? Simply add a `frontend/` folder (React, Next.js, Vue, etc.) at the root. 
- **Microservices/AI Ready**: You can easily plug in other services like `ml-service/` or `ai-apps/` in their own folders next to the backend.
- **Simplified Orchestration**: Any new service can be integrated into the root `docker-compose.yml` and CI/CD pipelines, ensuring your entire ecosystem remains easy to deploy in the cloud.

## 🤝 Contribution

We welcome contributions!
1. Fork the repo.
2. Clone it clearly.
3. Install dependencies: `uv sync` or `pip install -e .`
4. Add a new generator in `one_click_drf/generators.py` or new templates in `one_click_drf/templates/`.

## ⚙️ Configuration

On first run, `ocd` will ask for your GitHub and DockerHub usernames. These are saved in `~/.config/one-click-drf/config.toml` so you don't have to type them again.

---
[Back to Top](#top)
