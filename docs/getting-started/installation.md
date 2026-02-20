# Installation

## Prerequisites

- Python 3.12 or higher
- [uv](https://docs.astral.sh/uv/getting-started/installation/) package manager (recommended)
- Git

## Installing uv

If you don't have `uv` installed:

=== "macOS/Linux"
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```

=== "Windows"
    ```powershell
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    ```

## Installing One Click DRF

### Using uv (Recommended)

```bash
uv tool install one-click-drf
```

### Using pip

```bash
pip install one-click-drf
```

## Verify Installation

Check that the installation was successful:

```bash
ocd --version
```

You should see the version number displayed.

## Updating

To update to the latest version:

=== "uv"
    ```bash
    uv tool upgrade one-click-drf
    ```

=== "pip"
    ```bash
    pip install --upgrade one-click-drf
    ```

## Next Steps

Continue to the [Quick Start Guide](quickstart.md) to create your first project.
