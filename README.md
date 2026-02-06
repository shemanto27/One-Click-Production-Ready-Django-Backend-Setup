# One Click DRF (OCD) 🚀

**One Click DRF** is a powerful CLI tool designed to bootstrap **production-ready** Django REST Framework projects in seconds.

Stop copy-pasting code from old projects. Start with a solid foundation.

## 🌟 Why this tool?

Most Django tutorials teach you a basic structure. But in production, you need:
- Settings split into `base`, `dev`, `prod`.
- Docker & Docker Compose setup.
- CI/CD pipelines.
- Infrastructure as Code (Terraform).
- Observability (Prometheus/Grafana).

**ocd** gives you all of this with one command.

## 📦 Installation

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

## 🚩 CLI Flags

| Flag | Description |
|------|-------------|
| `--docker` | Adds `Dockerfile` and `docker-compose.yml` |
| `--ci-cd` | Adds GitHub Actions workflow for testing & linting |
| `--iac` | Adds Terraform skeleton for AWS |
| `--observability` | Adds Prometheus configuration |
| `--all` | Enables all above features |

## 📂 Project Structure

We follow a clean, modular structure:

```
project-root/
├── core/                 # Project configuration
│   ├── settings/         # Split settings
│   │   ├── base.py
│   │   ├── dev.py
│   │   ├── prod.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/                 # Your Django apps live here
├── requirements/         # Dependencies split
│   ├── base.txt
│   ├── dev.txt
│   └── prod.txt
├── manage.py
└── .env                  # Environment variables
```

**Why `core/`?** 
Keeping settings and configuration separate from your business logic (`apps/`) keeps the root directory clean and makes the project easier to navigate.

## 🤝 Contribution

We welcome contributions!
1. Fork the repo.
2. Clone it clearly.
3. Install dependencies: `uv sync` or `pip install -e .`
4. Add a new generator in `one_click_drf/generators.py` or new templates in `one_click_drf/templates/`.

## ⚙️ Configuration

On first run, `ocd` will ask for your GitHub and DockerHub usernames. These are saved in `~/.config/one-click-drf/config.toml` so you don't have to type them again.
