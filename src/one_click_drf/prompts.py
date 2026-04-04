import typer
from rich.console import Console
from one_click_drf.config import CONFIG_FILE, save_config, get_git_user, load_config

console = Console()

def ensure_global_config() -> dict:
    """
    Ensures global configuration exists.
    If not, prompts the user (only once).
    """
    if CONFIG_FILE.exists():
        cfg = load_config().get("user", {})
        return cfg

    console.print("[bold blue]📝 First-time setup - creating global config...[/bold blue]")
    console.print("Press [bold]ENTER[/bold] to skip any field.", style="dim")
    
    default_github = get_git_user()
    github_user = typer.prompt("GitHub Username", default=default_github, show_default=True)
    docker_user = typer.prompt("DockerHub Username", default="", show_default=False)
    
    save_config(github_user, docker_user)
    console.print(f"[green]✅ Configuration saved to {CONFIG_FILE}[/green]")
    
    return {"github_username": github_user, "dockerhub_username": docker_user}

def ask_project_info(default_name: str = "backend"):
    project_name = typer.prompt("Project Name", default=default_name)
    
    console.print("[dim]The 'users' app is added by default with pre-built models and auth APIs.[/dim]")
    console.print("[dim]Enter any ADDITIONAL Django apps you want to create (e.g., 'orders payments').[/dim]")
    console.print("[dim]Press Enter to skip additional apps.[/dim]")
    
    apps_input = typer.prompt("Additional app names (space separated)", default="")
    
    # Always include users by default
    apps_list = ["users"]
    if apps_input.strip():
        # Avoid duplicate 'users' if the user types it again
        additional_apps = [app for app in apps_input.split() if app != 'users']
        apps_list.extend(additional_apps)
        
    github_url = typer.prompt("GitHub Repository URL (optional)", default="", show_default=False)
    
    return {
        "project_name": project_name,
        "apps": apps_list,
        "github_url": github_url,
    }
