import typer
from pathlib import Path
from rich.console import Console
import importlib.metadata
import os
import subprocess

from one_click_drf.prompts import ask_project_info, ensure_global_config
from one_click_drf.generator import (
    generate_django_core,
    generate_docker,
    generate_cicd,
    generate_iac,
    generate_observability,
    setup_git
)

help_text="""
Initialize a Production Ready Django REST Framework project in One Click.

Made with ❤️ by Shemanto Sharkar
GitHub: https://github.com/shemanto27
LinkedIn: https://www.linkedin.com/in/shemanto/

Usage:
    ocd init [OPTIONS] [PATH]
    ocd update

Options:
    --all                       Enable everything
    --docker                    Include Docker support
    --ci-cd                     Include GitHub Actions
    --iac                       Include Terraform/Ansible
    --observability             Include Prometheus/Grafana
    --version                   Show the version and exit
    --help                      Show this message and exit

Examples:
    ocd init myproject
    ocd init myproject --all
    ocd update
"""

app = typer.Typer(help=help_text, add_completion=False)
console = Console()

def get_version():
    try:
        return importlib.metadata.version("one-click-drf")
    except importlib.metadata.PackageNotFoundError:
        return "dev"

def version_callback(value: bool):
    if value:
        typer.echo(f"one-click-drf v{get_version()}")
        raise typer.Exit()

@app.callback()
def main(
    version: bool = typer.Option(
        None, "--version", "-v", help="Show the version and exit", callback=version_callback, is_eager=True
    ),
):
    pass

@app.command()
def init(
    path: Path = typer.Argument(None, help="Project name or path. Use '.' for current directory.", show_default=False),
    docker: bool = typer.Option(False, "--docker", help="Include Docker support"),
    ci_cd: bool = typer.Option(False, "--ci-cd", help="Include GitHub Actions"),
    iac: bool = typer.Option(False, "--iac", help="Include Terraform/Ansible"),
    observability: bool = typer.Option(False, "--observability", help="Include Prometheus/Grafana"),
    all_features: bool = typer.Option(False, "--all", help="Enable everything"),
):
    """
    Initialize a new production-ready Django project.
    """
    if all_features:
        docker = ci_cd = iac = observability = True

    # Ensure config first
    global_config = ensure_global_config()

    # Determine Project Root and Name
    if path is None:
        # Ask for name, create dir
        info = ask_project_info()
        project_name = info["project_name"]
        project_root = Path.cwd() / project_name
        if project_root.exists() and any(project_root.iterdir()):
             console.print(f"[bold red]❌ Directory {project_name} already exists and is not empty.[/bold red]")
             raise typer.Exit(code=1)
        project_root.mkdir(exist_ok=True)
    elif str(path) == ".":
        # Use current dir
        project_root = Path.cwd()
        # Default name is current dir name
        info = ask_project_info(default_name=project_root.name)
        project_name = info["project_name"]
    else:
        # Path provided (e.g. ./myproject)
        project_root = path.resolve()
        default_name = path.name
        project_root.mkdir(parents=True, exist_ok=True)
        
        console.print(f"[dim]Using target directory: {project_root}[/dim]")
        info = ask_project_info(default_name=default_name)
        project_name = info["project_name"]

    # Merge context and sanitize
    # Project name and app names must be valid Python identifiers (or close enough for paths)
    import re
    def sanitize_identifier(name: str) -> str:
        # Keep only alphanumeric and underscores
        return re.sub(r"[^a-zA-Z0-9_]", "", name)

    project_name_safe = re.sub(r"[^a-zA-Z0-9_]", "_", project_name)
    apps_safe = [sanitize_identifier(app) for app in info["apps"] if sanitize_identifier(app)]

    context = {
        "project_name": project_name_safe,
        "apps": apps_safe,
        "github_username": global_config.get("github_username", ""),
        "dockerhub_username": global_config.get("dockerhub_username", ""),
        "github_repository_url": info.get("github_url", ""),
        "website_domain": info.get("website_domain", f"{project_name_safe}.com"),
    }

    console.print(f"\n[bold green]🚀 Initializing {project_name} in {project_root}...[/bold green]")

    # Generate Core (Mandatory)
    with console.status("Generating Django Core & Dependencies...") as status:
        generate_django_core(project_root, context)
        console.print("[green]✓ Django Core generated[/green]")

    if docker:
        with console.status("Generating Docker files..."):
            generate_docker(project_root, context)
            console.print("[green]✓ Docker files generated[/green]")

    if ci_cd:
        with console.status("Generating CI/CD workflows..."):
            generate_cicd(project_root, context)
            console.print("[green]✓ CI/CD workflows generated[/green]")

    if iac:
        with console.status("Generating IaC templates..."):
            generate_iac(project_root, context)
            console.print("[green]✓ IaC templates generated[/green]")
            
    if observability:
        with console.status("Generating Observability configs..."):
            generate_observability(project_root, context)
            console.print("[green]✓ Observability configs generated[/green]")

    # Git setup (Must be last to capture all files)
    setup_git(project_root, context.get("github_repository_url", ""))
    
    # Final Instruction
    console.print("\n[bold green]✨ Project initialized successfully![/bold green]")
    console.print(f"\nNext steps:")
    if str(path) != ".":
        console.print(f"  cd {project_root.name if path else project_name}")
    
    console.print("\n[bold]Run with Docker:[/bold]")
    console.print("  docker compose -f docker-compose.dev.yml up --build")
    
    console.print("\n[bold]Run Locally:[/bold]")
    console.print("  cd backend")
    console.print("  source .venv/bin/activate")
    console.print("  python manage.py runserver")
    
    console.print("\n[bold blue]Superuser Created:[/bold blue]")
    console.print("  Email:    admin@gmail.com")
    console.print("  Password: admin123")

@app.command()
def update():
    """
    Update the one-click-drf package to the latest version.
    """
    console.print("[bold blue]Checking for updates...[/bold blue]")
    try:
        # Check if installed via uv
        result = subprocess.run(["uv", "tool", "upgrade", "one-click-drf"], capture_output=True, text=True)
        if result.returncode == 0:
            console.print("[green]Successfully updated to the latest version via uv![/green]")
            console.print(result.stdout)
        else:
            # Try pip
            console.print("[yellow]uv upgrade failed or uv not found. Trying pip...[/yellow]")
            result = subprocess.run(["pip", "install", "--upgrade", "one-click-drf"], capture_output=True, text=True)
            if result.returncode == 0:
                console.print("[green]Successfully updated via pip![/green]")
            else:
                console.print("[red]Update failed. Please run 'uv tool upgrade one-click-drf' or 'pip install --upgrade one-click-drf' manually.[/red]")
    except Exception as e:
        console.print(f"[red]Error during update: {e}[/red]")

@app.command()
def version():
    typer.echo(f"one-click-drf v{get_version()}")

if __name__ == "__main__":
    app()
