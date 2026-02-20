from typing import Any

import typer
from rich.console import Console

from one_click_drf.config import CONFIG_FILE, get_git_user, load_config, save_config

console = Console()


def ensure_global_config() -> dict[str, Any]:
    """
    Ensures global configuration exists.
    If not, prompts the user (only once).
    """
    if CONFIG_FILE.exists():
        cfg = load_config().get("user", {})
        return dict(cfg) if cfg else {}

    console.print("[bold blue]📝 First-time setup - creating global config...[/bold blue]")
    console.print("Press [bold]ENTER[/bold] to skip any field.", style="dim")

    default_github = get_git_user()
    github_user = typer.prompt("GitHub Username", default=default_github, show_default=True)
    docker_user = typer.prompt("DockerHub Username", default="", show_default=False)

    save_config(github_user, docker_user)
    console.print(f"[green]✅ Configuration saved to {CONFIG_FILE}[/green]")

    return {"github_username": github_user, "dockerhub_username": docker_user}


def ask_project_info(default_name: str = "backend") -> dict[str, Any]:
    project_name = typer.prompt("Project Name", default=default_name)

    console.print("[dim]Enter the names of Django apps you want to create (e.g., 'users orders payments').[/dim]")
    console.print("[dim]Press Enter to use the default ('users') or type 'none' for no apps.[/dim]")

    apps_input = typer.prompt("App names (space separated)", default="users")

    if apps_input.lower().strip() == "none":
        apps_list = []
    else:
        apps_list = apps_input.split()

    github_url = typer.prompt("GitHub Repository URL (optional)", default="", show_default=False)

    return {
        "project_name": project_name,
        "apps": apps_list,
        "github_url": github_url,
    }
