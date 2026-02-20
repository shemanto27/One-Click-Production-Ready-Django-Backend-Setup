# CLI Commands

## ocd init

Initialize a new Django REST Framework project.

### Usage

```bash
ocd init [PATH] [OPTIONS]
```

### Arguments

- `PATH` - Project name or path (optional)
  - If omitted, you'll be prompted for a name
  - Use `.` to initialize in the current directory

### Options

| Option | Description |
|--------|-------------|
| `--docker` | Include Docker support (Dockerfile, docker-compose) |
| `--ci-cd` | Include GitHub Actions workflows |
| `--iac` | Include Terraform and Ansible templates |
| `--observability` | Include Prometheus monitoring |
| `--all` | Enable all features above |

### Examples

**Create project with all features:**
```bash
ocd init myproject --all
```

**Create project with specific features:**
```bash
ocd init myproject --docker --ci-cd
```

**Initialize in current directory:**
```bash
ocd init .
```

**Minimal project (no optional features):**
```bash
ocd init myproject
```

## ocd version

Display the installed version of One Click DRF.

### Usage

```bash
ocd version
# or
ocd --version
```

## Configuration

On first run, `ocd` will prompt for:

- **GitHub Username**: Used in generated files
- **DockerHub Username**: Used in Docker configurations

These are saved in `~/.config/one-click-drf/config.toml` and won't be asked again.

### Manual Configuration

Edit the config file directly:

```toml
[user]
github_username = "your-username"
dockerhub_username = "your-dockerhub"
```
