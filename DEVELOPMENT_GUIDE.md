# 🛠️ Development & Contribution Guide

This guide explains how to set up the project locally, contribute code, and how maintainers can publish new versions to PyPI.

---

## 🤝 How to Contribute

We welcome contributions! To contribute to **One Click DRF**, follow these steps:

1. **Fork the Repository**: Create a fork of the repo on your GitHub account.
2. **Clone the Repo**:
   ```bash
   git clone https://github.com/your-username/One-Click-Production-Ready-Django-Backend-Setup.git
   cd One-Click-Production-Ready-Django-Backend-Setup
   ```
3. **Set Up Local Environment**:
   We use `uv` for dependency management. If you don't have it, install it from [astral.sh/uv](https://astral.sh/uv/install.sh).
   ```bash
   # Sync dependencies and create virtual environment
   uv sync
   ```
4. **Make Your Changes**:
   - Add new features or generators in `src/one_click_drf/generator.py`.
   - Add or update templates in `src/one_click_drf/templates/`.
   - Update the CLI logic in `src/one_click_drf/cli.py`.
5. **Test Your Changes**:
   Follow the [Local Installation](#-local-installation) section below to test your changes.

---

## 🚀 Local Installation

After making changes to the source code, you need to install the package locally to test the `ocd` command.

### Option 1: Editable Install (Recommended for Development)
This allows you to see changes immediately without re-installing.
```bash
uv pip install -e .
```

### Option 2: Build and Install Tool
If you want to test the package as a standalone tool:
```bash
# 1. Clean old builds
rm -rf dist build *.egg-info

# 2. Build the package
uv build

# 3. Install the specific wheel file
uv tool install dist/one_click_drf-*.whl --force
```

### 🧪 Verifying the Changes
```bash
# Check if ocd works
ocd --version
ocd --help

# Create a demo project to see if templates generate correctly
ocd init demo_project --all
```

---

## 🔑 Admin: Publishing to PyPI

Only project maintainers can publish new versions. Follow these steps carefully to ensure a smooth release.

### 1. Update Version
Before publishing, you **MUST** update the version number in `pyproject.toml`:
```toml
# pyproject.toml
[project]
name = "one-click-drf"
version = "1.1.11" # Update this to the next version (e.g., 1.1.10 -> 1.1.11)
```

### 2. Commit and Tag
Tagging is crucial because the GitHub Action for publishing is triggered by tags.
```bash
# 1. Stage and commit changes
git add .
git commit -m "Chore: Release version 1.1.11"

# 2. Create a git tag (must match the version in pyproject.toml)
git tag v1.1.11

# 3. Push code to main
git push origin main

# 4. Push the tag to trigger the Publish Action
git push origin v1.1.11
```

### 3. Automated vs. Manual Publish
- **Automated (Recommended)**: Once the tag is pushed, the `Publish to PyPI` GitHub Action will automatically build and upload the package.
- **Manual (Backup)**:
  ```bash
  uv build
  uv run twine upload dist/*
  ```

---

## 🛠️ Typical Development Workflow
```bash
# Checkout to dev branch
git checkout dev

# Make changes...

# Commit changes
git commit -m "Add new feature"
git push origin dev

# Merge to main when ready
git checkout main
git merge dev
# Then follow the Admin steps above to release
```