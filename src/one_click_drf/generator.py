from jinja2 import Environment, FileSystemLoader, TemplateNotFound
from pathlib import Path
import os
import secrets
import shutil
import subprocess
import sys
from rich.console import Console

console = Console()

TEMPLATE_DIR = Path(__file__).parent / "templates"
env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))

def render_to_file(template_name: str, context: dict, dest_path: Path):
    try:
        template = env.get_template(template_name)
        content = template.render(**context)
        dest_path.parent.mkdir(parents=True, exist_ok=True)
        dest_path.write_text(content)
    except TemplateNotFound:
        console.print(f"[bold red]❌ Template missing: {template_name}[/bold red]")

def run_command(cmd: list, cwd: Path, description: str = ""):
    """Run a shell command silently"""
    try:
        # Check if environment is needed (specifically for running manage.py)
        # We need to make sure we're using the UV environment
        env = os.environ.copy()
        
        subprocess.run(
            cmd,
            cwd=cwd,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            env=env
        )
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed: {description}[/bold red]")
        console.print(e.stderr.decode().strip())
        # Don't strictly raise, allow continuation if minor
        # but for migrations it might be critical.
        if "migrate" in str(cmd) or "createsuperuser" in str(cmd):
             console.print("[yellow]Continuing despite error...[/yellow]")
        else:
             raise
    except Exception as e:
        console.print(f"[bold red]❌ Execution failed: {e}[/bold red]")

def setup_uv(project_root: Path):
    """
    Checks for uv, installs if missing, initializes project, and adds dependencies.
    Replicates init.sh logic.
    """
    if shutil.which("uv") is None:
        console.print("[yellow]uv is not installed. Installing uv...[/yellow]")
        install_cmd = "curl -LsSf https://astral.sh/uv/install.sh | sh"
        subprocess.run(install_cmd, shell=True, check=True)
        uv_bin = Path.home() / ".local" / "bin" / "uv"
        if uv_bin.exists():
            import os
            os.environ["PATH"] += os.pathsep + str(uv_bin.parent)

    console.print("Initializing uv project...")
    run_command(["uv", "init", "--no-workspace", "."], cwd=project_root, description="uv init")
    
    main_py = project_root / "main.py" 
    if main_py.exists():
        main_py.unlink()

    hello_py = project_root / "hello.py"
    if hello_py.exists():
        hello_py.unlink()

    console.print("Installing Django and core dependencies...")
    core_deps = [
        "django",
        "django-cors-headers",
        "djangorestframework",
        "djangorestframework-simplejwt",
        "drf-yasg",
        "isort>=5.13.2",
        "black>=24.4.2",
        "python-decouple",
        "django-extensions",
        "gunicorn",
        "whitenoise",
        "psycopg2-binary",
        "sentry-sdk[django]",
        "boto3",
        "django-storages",
        "pre-commit>=3.6.0"
    ]
    run_command(["uv", "add", "--no-workspace"] + core_deps, cwd=project_root, description="uv add dependencies")

def setup_django_db(project_root: Path):
    """Run migrations and create superuser"""
    console.print("Running migrations...")
    # 'uv run' executes in the context of the project
    run_command(["uv", "run", "python", "manage.py", "makemigrations"], cwd=project_root, description="makemigrations")
    run_command(["uv", "run", "python", "manage.py", "migrate"], cwd=project_root, description="migrate")

    # Superuser logic matching init.sh
    # In init.sh: it parses .env for export. We have to be careful.
    # We can invoke createsuperuser --noinput if we set environment variables.
    
    # Read .env to get creds
    env_file = project_root / ".env"
    env_vars = {}
    if env_file.exists():
        with open(env_file, "r") as f:
            for line in f:
                if "=" in line and not line.strip().startswith("#"):
                    key, val = line.strip().split("=", 1)
                    env_vars[key] = val
    
    su_user = env_vars.get("DJANGO_SUPERUSER_USERNAME")
    su_email = env_vars.get("DJANGO_SUPERUSER_EMAIL")
    su_pass = env_vars.get("DJANGO_SUPERUSER_PASSWORD")

    if su_user and su_pass:
        console.print(f"Creating superuser '{su_user}'...")
        # create env dictionary for the subprocess
        proc_env = os.environ.copy()
        proc_env.update({
            "DJANGO_SUPERUSER_USERNAME": su_user,
            "DJANGO_SUPERUSER_EMAIL": su_email,
            "DJANGO_SUPERUSER_PASSWORD": su_pass,
        })
        
        # We must use subprocess run manually here to inject env
        try:
             subprocess.run(
                ["uv", "run", "python", "manage.py", "createsuperuser", "--noinput"],
                cwd=project_root,
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                env=proc_env
            )
             console.print("[green]Superuser created successfully![/green]")
        except subprocess.CalledProcessError:
             console.print("[yellow]Superuser already exists or failed to create.[/yellow]")

def setup_git(project_root: Path, github_url: str):
    """
    Initializes git, creates README if missing, commits, and pushes to GitHub.
    Replicates init.sh logic.
    """
    if not github_url:
        console.print("[yellow]GitHub setup skipped (no URL provided).[/yellow]")
        return

    console.print(f"Initializing Git repository and pushing to {github_url}...")
    
    ssh_url = github_url
    if "https://github.com/" in github_url:
         repo_path = github_url.replace("https://github.com/", "")
         repo_path = repo_path.rstrip("/")
         if repo_path.endswith(".git"):
             repo_path = repo_path[:-4]
         ssh_url = f"git@github.com:{repo_path}.git"

    run_command(["git", "init"], cwd=project_root, description="git init")
    
    if not (project_root / "README.md").exists():
        (project_root / "README.md").write_text("# Project Created with One-Click Production-Ready Django Setup")

    run_command(["git", "add", "."], cwd=project_root, description="git add")
    run_command(["git", "commit", "-m", "initial project setup"], cwd=project_root, description="git commit")
    run_command(["git", "branch", "-M", "main"], cwd=project_root, description="git branch")
    
    try:
        subprocess.run(["git", "remote", "remove", "origin"], cwd=project_root, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except:
        pass
        
    run_command(["git", "remote", "add", "origin", ssh_url], cwd=project_root, description="git remote add")

    console.print(f"Pushing to {ssh_url}...")
    try:
        subprocess.run(["git", "push", "-u", "origin", "main"], cwd=project_root, check=True)
        console.print("[green]Code pushed to GitHub successfully![/green]")
    except subprocess.CalledProcessError:
        console.print("[bold red]❌ Failed to push to GitHub. Check your SSH keys or permissions.[/bold red]")


def generate_django_core(project_root: Path, context: dict):
    """Generates the core Django project structure."""
    
    setup_uv(project_root)

    # Define mapping of template -> destination
    files_map = {
        # Using single settings.py now, per user request
        "django/settings.py.jinja": project_root / "core" / "settings.py", 
        "django/__init__.py.jinja": project_root / "core" / "__init__.py",
        "django/urls.py.jinja": project_root / "core" / "urls.py",
        "django/wsgi.py.jinja": project_root / "core" / "wsgi.py",
        "django/asgi.py.jinja": project_root / "core" / "asgi.py",
        "django/manage.py.jinja": project_root / "manage.py",
        "env/.env.jinja": project_root / ".env",
        "env/.gitignore.jinja": project_root / ".gitignore",
        "django/erd.sh.jinja": project_root / "erd.sh",
        "django/__init__.py.jinja": project_root / "apps" / "__init__.py", # Ensure apps folder is a package too? Optional but good.
        
        # Legacy requirements files
        "django/requirements/base.txt.jinja": project_root / "requirements" / "base.txt",
        "django/requirements/dev.txt.jinja": project_root / "requirements" / "dev.txt",
        "django/requirements/prod.txt.jinja": project_root / "requirements" / "prod.txt",
    }
    
    context.setdefault("secret_key", secrets.token_urlsafe(50))
    
    for tmpl, dest in files_map.items():
        render_to_file(tmpl, context, dest)
    
    (project_root / "manage.py").chmod(0o755)
    (project_root / "erd.sh").chmod(0o755)

    apps_dir = project_root / "apps"
    apps_dir.mkdir(exist_ok=True)
    
    for app in context.get("apps", []):
        app_path = apps_dir / app
        app_path.mkdir(exist_ok=True)
        (app_path / "__init__.py").touch()
        
        apps_py_content = f"""from django.apps import AppConfig

class {app.capitalize()}Config(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.{app}'
    label = 'apps_{app}'
"""
        (app_path / "apps.py").write_text(apps_py_content)
        (app_path / "models.py").write_text("from django.db import models\n\n# Create your models here.")
        (app_path / "views.py").write_text("from django.shortcuts import render\n\n# Create your views here.")
        (app_path / "tests.py").write_text("from django.test import TestCase\n\n# Create your tests here.")
        
        urls_py_content = """from django.urls import path

urlpatterns = [
    # Add your routes here
]
"""
        (app_path / "urls.py").write_text(urls_py_content)
        (app_path / "serializers.py").write_text("from rest_framework import serializers\n\n# Create your serializers here.")
        (app_path / "admin.py").write_text("from django.contrib import admin\n\n# Register your models here.")
        
    # Run DB setup (migrations + superuser) AFTER all generation
    # Needs to run inside uv context
    setup_django_db(project_root)

    setup_git(project_root, context.get("github_repository_url", ""))


def generate_docker(project_root: Path, context: dict):
    render_to_file("docker/Dockerfile.jinja", context, project_root / "Dockerfile")
    render_to_file("docker/.dockerignore.jinja", context, project_root / ".dockerignore")
    render_to_file("docker/entrypoint.sh.jinja", context, project_root / "entrypoint.sh")
    render_to_file("docker/docker-compose.dev.yml.jinja", context, project_root / "docker-compose.dev.yml")
    render_to_file("docker/docker-compose.prod.yml.jinja", context, project_root / "docker-compose.prod.yml")
    render_to_file("docker/docker-compose.dev.yml.jinja", context, project_root / "docker-compose.yml")
    
    (project_root / "entrypoint.sh").chmod(0o755)

def generate_cicd(project_root: Path, context: dict):
    render_to_file("github/pipeline.yml.jinja", context, project_root / ".github" / "workflows" / "pipeline.yml")

def generate_iac(project_root: Path, context: dict):
    render_to_file("iac/terraform/main.tf.jinja", context, project_root / "infra" / "terraform" / "main.tf")
    render_to_file("iac/terraform/outputs.tf.jinja", context, project_root / "infra" / "terraform" / "outputs.tf")
    render_to_file("iac/terraform/provider.tf.jinja", context, project_root / "infra" / "terraform" / "provider.tf")
    render_to_file("iac/terraform/security_groups.tf.jinja", context, project_root / "infra" / "terraform" / "security_groups.tf")
    render_to_file("iac/terraform/variables.tf.jinja", context, project_root / "infra" / "terraform" / "variables.tf")

    render_to_file("iac/ansible/hosts.ini.jinja", context, project_root / "infra" / "ansible" / "hosts.ini")
    render_to_file("iac/ansible/playbook.yml.jinja", context, project_root / "infra" / "ansible" / "playbook.yml")

def generate_observability(project_root: Path, context: dict):
    render_to_file("observability/prometheus.yml.jinja", context, project_root / "prometheus.yml")
