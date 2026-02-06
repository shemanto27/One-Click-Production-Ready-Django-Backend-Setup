import typer
from pathlib import Path
from rich.console import Console

from one_click_drf.prompts import ask_project_info, ensure_global_config
from one_click_drf.generator import (
    generate_django_core,
    generate_docker,
    generate_cicd,
    generate_iac,
    generate_observability
)

app = typer.Typer(help="Initialize a Production Ready Django REST Framework project")
console = Console()

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

    # Merge context
    context = {
        "project_name": project_name.replace(" ", "_").replace("-", "_"), # Safe python name
        "apps": info["apps"],
        "github_username": global_config.get("github_username", ""),
        "dockerhub_username": global_config.get("dockerhub_username", ""),
        "github_repository_url": info.get("github_url", ""),
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
    
    # Final Instruction
    console.print("\n[bold green]✨ Project initialized successfully![/bold green]")
    console.print(f"\nNext steps:")
    if str(path) != ".":
        console.print(f"  cd {project_root.name if path else project_name}")
    
    console.print("  source .venv/bin/activate")
    console.print("  python manage.py runserver")
    
    console.print("\n[bold blue]Superuser Created:[/bold blue]")
    console.print("  Email:    admin@gmail.com")
    console.print("  Password: admin123")

@app.command()
def version():
    typer.echo("one-click-drf v0.1.0")

if __name__ == "__main__":
    app()
