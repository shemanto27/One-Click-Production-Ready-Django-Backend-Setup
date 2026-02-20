# Contributing to One Click DRF

Thank you for your interest in contributing to One Click DRF! 🎉

## Getting Started

### Prerequisites
- Python 3.12+
- [uv](https://docs.astral.sh/uv/getting-started/installation/) package manager
- Git

### Setup Development Environment

1. **Fork and clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/One-Click-Production-Ready-Django-Backend-Setup.git
cd One-Click-Production-Ready-Django-Backend-Setup
```

2. **Install dependencies**
```bash
uv sync
```

3. **Install pre-commit hooks**
```bash
uv run pre-commit install
```

4. **Install the package in editable mode**
```bash
uv pip install -e .
```

## Development Workflow

### Running the CLI locally
```bash
uv run ocd init test_project --all
```

### Code Quality

We use **Ruff** for linting and formatting:

```bash
# Format code
uv run ruff format .

# Lint and auto-fix
uv run ruff check --fix .

# Check without fixing
uv run ruff check .
```

**Type checking with mypy:**

```bash
uv run mypy src/one_click_drf
```

**Security scanning with bandit:**

```bash
uv run bandit -r src/one_click_drf -c pyproject.toml
```

### Testing

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov

# Run specific test file
uv run pytest tests/test_cli.py
```

### Pre-commit Hooks

Pre-commit hooks run automatically on `git commit`. To run manually:

```bash
uv run pre-commit run --all-files
```

## Making Changes

### Branch Naming
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

### Commit Messages
Follow conventional commits:
- `feat: add new generator for FastAPI`
- `fix: resolve template rendering issue`
- `docs: update installation guide`
- `test: add tests for config module`
- `refactor: simplify generator logic`

### Pull Request Process

1. **Create a feature branch**
```bash
git checkout -b feature/your-feature-name
```

2. **Make your changes**
   - Write clean, readable code
   - Add tests for new functionality
   - Update documentation if needed

3. **Run quality checks**
```bash
uv run ruff format .
uv run ruff check --fix .
uv run mypy src/one_click_drf
uv run bandit -r src/one_click_drf -c pyproject.toml
uv run pytest
```

4. **Commit your changes**
```bash
git add .
git commit -m "feat: your descriptive message"
```

5. **Push to your fork**
```bash
git push origin feature/your-feature-name
```

6. **Open a Pull Request**
   - Use the PR template
   - Link related issues
   - Provide clear description of changes

## Project Structure

```
src/one_click_drf/
├── cli.py           # CLI entry point (Typer commands)
├── generator.py     # Project generation logic
├── config.py        # User configuration management
├── prompts.py       # Interactive user prompts
└── templates/       # Jinja2 templates for generated files
```

## Adding New Features

### Adding a New Generator

1. Create template in `src/one_click_drf/templates/`
2. Add generator function in `generator.py`
3. Wire it up in `cli.py`
4. Add tests in `tests/`

Example:
```python
def generate_new_feature(project_root: Path, context: dict):
    render_to_file("feature/template.jinja", context, project_root / "output.txt")
```

### Adding New CLI Options

Edit `cli.py`:
```python
@app.command()
def init(
    new_option: bool = typer.Option(False, "--new-option", help="Description"),
):
    if new_option:
        generate_new_feature(project_root, context)
```

## Testing Guidelines

- Write tests for all new features
- Maintain or improve code coverage
- Test edge cases and error handling
- Use descriptive test names

### Running Tests with Tox

Test across multiple Python versions:

```bash
# Run all test environments
uv run tox

# Run specific environment
uv run tox -e py312
uv run tox -e lint
uv run tox -e type
uv run tox -e docs
```

## Documentation

- Update README.md for user-facing changes
- Add docstrings to functions and classes
- Update CHANGELOG.md (maintainers will handle this)
- Build and preview docs locally:
  ```bash
  uv run mkdocs serve
  ```

## Code Style

- Follow PEP 8 (enforced by Ruff)
- Use type hints where appropriate
- Keep functions focused and small
- Write self-documenting code

## Getting Help

- Open an issue for bugs or feature requests
- Join discussions in existing issues
- Reach out to maintainers: [@shemanto27](https://github.com/shemanto27)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

Thank you for contributing! 🚀
