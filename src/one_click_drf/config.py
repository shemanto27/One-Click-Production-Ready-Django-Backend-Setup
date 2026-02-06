from pathlib import Path
import subprocess
try:
    import tomllib
except ImportError:
    import toml as tomllib # Fallback if needed, though pyproject says >=3.12
from typing import Dict, Any, Optional

APP_NAME = "one-click-drf"
CONFIG_DIR = Path.home() / ".config" / APP_NAME
CONFIG_FILE = CONFIG_DIR / "config.toml"

def get_git_user() -> str:
    """Attempt to get the git global user name."""
    try:
        result = subprocess.run(
            ["git", "config", "--global", "user.name"],
            capture_output=True,
            text=True,
            check=False
        )
        return result.stdout.strip()
    except Exception:
        return ""

def load_config() -> Dict[str, Any]:
    """Load configuration from the local config file."""
    if not CONFIG_FILE.exists():
        return {}
    try:
        with open(CONFIG_FILE, "rb") as f:
            return tomllib.load(f)
    except Exception:
        return {}

def save_config(github_username: str, dockerhub_username: str):
    """Save configuration to the local config file."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    
    # Simple TOML dumping
    content = f"""[user]
github_username = "{github_username}"
dockerhub_username = "{dockerhub_username}"
"""
    with open(CONFIG_FILE, "w") as f:
        f.write(content)

def get_config_value(key: str, default: str = "") -> str:
    """Get a specific config value from the [user] table."""
    config = load_config()
    return config.get("user", {}).get(key, default)
